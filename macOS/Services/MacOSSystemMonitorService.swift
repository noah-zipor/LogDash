import Foundation
import Darwin
import IOKit.ps

class MacOSSystemMonitorService: SystemMonitorServiceProtocol {

    // CPU: store previous ticks to compute delta-based usage (far more accurate)
    private var prevUser: Double = 0
    private var prevSystem: Double = 0
    private var prevIdle: Double = 0

    func getStats() -> SystemStats {
        return SystemStats(
            cpuUsage: getCPUUsage(),
            memoryUsage: getMemoryUsage(),
            diskUsage: getDiskUsage(),
            batteryLevel: getBatteryLevel(),
            isCharging: getIsCharging()
        )
    }

    // MARK: - CPU Usage (delta-based for accuracy)

    private func getCPUUsage() -> Double {
        var load = host_cpu_load_info()
        var size = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &load) { ptr -> kern_return_t in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { reboundPtr in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, reboundPtr, &size)
            }
        }

        guard result == KERN_SUCCESS else { return 0.0 }

        let user   = Double(load.cpu_ticks.0)
        let system = Double(load.cpu_ticks.1)
        let idle   = Double(load.cpu_ticks.2)

        let deltaUser   = user   - prevUser
        let deltaSystem = system - prevSystem
        let deltaIdle   = idle   - prevIdle
        let deltaTotal  = deltaUser + deltaSystem + deltaIdle

        prevUser   = user
        prevSystem = system
        prevIdle   = idle

        guard deltaTotal > 0 else { return 0 }
        return ((deltaUser + deltaSystem) / deltaTotal) * 100.0
    }

    // MARK: - Memory Usage

    private func getMemoryUsage() -> Double {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &stats) { ptr -> kern_return_t in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { reboundPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, reboundPtr, &size)
            }
        }

        guard result == KERN_SUCCESS else { return 0.0 }

        let active   = Double(stats.active_count)
        let inactive = Double(stats.inactive_count)
        let wired    = Double(stats.wire_count)
        let free     = Double(stats.free_count)

        let total = active + inactive + wired + free
        guard total > 0 else { return 0 }

        return ((active + wired) / total) * 100.0
    }

    // MARK: - Disk Usage

    private func getDiskUsage() -> Double {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: "/")
            if let total = attrs[.systemSize] as? Int64,
               let free  = attrs[.systemFreeSize] as? Int64,
               total > 0 {
                let used = total - free
                return (Double(used) / Double(total)) * 100.0
            }
        } catch {}
        return -1.0
    }

    // MARK: - Battery

    private func getBatteryLevel() -> Double {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let desc = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any] else {
            return -1.0
        }
        if let capacity = desc[kIOPSCurrentCapacityKey] as? Int {
            return Double(capacity)
        }
        return -1.0
    }

    private func getIsCharging() -> Bool {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let desc = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any] else {
            return false
        }
        return (desc[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue
    }
}
