import Foundation
import Darwin

class MacOSSystemMonitorService: SystemMonitorServiceProtocol {

    func getStats() -> SystemStats {
        return SystemStats(
            cpuUsage: getCPUUsage(),
            memoryUsage: getMemoryUsage()
        )
    }

    // MARK: - CPU Usage

    private func getCPUUsage() -> Double {
        var load = host_cpu_load_info()
        var size = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &load) { ptr -> kern_return_t in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { reboundPtr in
                host_statistics(
                    mach_host_self(),
                    HOST_CPU_LOAD_INFO,
                    reboundPtr,
                    &size
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return 0.0
        }

        let user = Double(load.cpu_ticks.0)
        let system = Double(load.cpu_ticks.1)
        let idle = Double(load.cpu_ticks.2)

        let total = user + system + idle
        guard total > 0 else { return 0 }

        return ((user + system) / total) * 100.0
    }

    // MARK: - Memory Usage

    private func getMemoryUsage() -> Double {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &stats) { ptr -> kern_return_t in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { reboundPtr in
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    reboundPtr,
                    &size
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return 0.0
        }

        let active = Double(stats.active_count)
        let inactive = Double(stats.inactive_count)
        let wired = Double(stats.wire_count)   // Modern SDK uses wire_count
        let free = Double(stats.free_count)

        let total = active + inactive + wired + free
        guard total > 0 else { return 0 }

        return ((active + wired) / total) * 100.0
    }
}
