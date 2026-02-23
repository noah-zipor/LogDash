using System;
using System.Diagnostics;
using StartupDashboard.Core;

namespace StartupDashboard.Services
{
    public class WindowsSystemMonitorService : ISystemMonitorService
    {
        private readonly PerformanceCounter _cpuCounter;
        private readonly PerformanceCounter _ramCounter;

        public WindowsSystemMonitorService()
        {
            _cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            _ramCounter = new PerformanceCounter("Memory", "% Committed Bytes In Use");
        }

        public SystemStats GetStats()
        {
            return new SystemStats
            {
                CpuUsage = _cpuCounter.NextValue(),
                MemoryUsage = _ramCounter.NextValue()
            };
        }
    }
}
