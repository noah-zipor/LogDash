namespace StartupDashboard.Core
{
    public interface IAuthService
    {
        bool Authenticate(string password);
        void SetPassword(string newPassword);
        bool IsPasswordSet();
    }

    public interface IMediaService
    {
        MediaInfo GetCurrentMedia();
        event EventHandler<MediaInfo> MediaChanged;
    }

    public class MediaInfo
    {
        public string Title { get; set; } = "";
        public string Artist { get; set; } = "";
        public byte[]? AlbumArt { get; set; }
        public bool IsPlaying { get; set; }
    }

    public interface IAppService
    {
        IEnumerable<AppEntry> GetInstalledApps();
        void LaunchApp(AppEntry? app);
    }

    public class AppEntry
    {
        public string Name { get; set; } = "";
        public string ExecutablePath { get; set; } = "";
        public byte[]? Icon { get; set; }
    }

    public interface IStartupService
    {
        bool IsRegisteredForStartup();
        void RegisterForStartup();
        void UnregisterFromStartup();
    }

    public class SystemStats
    {
        public double CpuUsage    { get; set; }
        public double MemoryUsage { get; set; }
        /// <summary>0–100 % disk used, or -1 if unavailable.</summary>
        public double DiskUsage   { get; set; } = -1;
        /// <summary>0–100 % battery, or -1 for desktops/unavailable.</summary>
        public double BatteryLevel { get; set; } = -1;
        public bool   IsCharging  { get; set; }
    }

    public interface ISystemMonitorService
    {
        SystemStats GetStats();
    }
}
