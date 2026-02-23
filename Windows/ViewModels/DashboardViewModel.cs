using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using System.Windows.Threading;
using StartupDashboard.Core;
using StartupDashboard.UI;

namespace StartupDashboard.ViewModels
{
    public class DashboardViewModel : INotifyPropertyChanged
    {
        private readonly IMediaService _mediaService;
        private readonly IAppService _appService;
        private readonly ISystemMonitorService _systemMonitor;

        private string _currentTime = "";
        private string _currentDate = "";
        private MediaInfo? _nowPlaying;
        private ObservableCollection<AppEntry> _apps = new();
        private SystemStats _systemStats = new SystemStats();
        private string _searchQuery = "";

        public string CurrentTime
        {
            get => _currentTime;
            set { _currentTime = value; OnPropertyChanged(); }
        }

        public string CurrentDate
        {
            get => _currentDate;
            set { _currentDate = value; OnPropertyChanged(); }
        }

        public MediaInfo? NowPlaying
        {
            get => _nowPlaying;
            set { _nowPlaying = value; OnPropertyChanged(); OnPropertyChanged(nameof(IsNowPlayingVisible)); }
        }

        public bool IsNowPlayingVisible => NowPlaying?.IsPlaying == true;

        public ObservableCollection<AppEntry> Apps
        {
            get => _apps;
            set { _apps = value; OnPropertyChanged(); OnPropertyChanged(nameof(FilteredApps)); }
        }

        public SystemStats SystemStats
        {
            get => _systemStats;
            set { _systemStats = value; OnPropertyChanged(); OnPropertyChanged(nameof(IsBatteryVisible)); }
        }

        public bool IsBatteryVisible => SystemStats.BatteryLevel >= 0;

        public string SearchQuery
        {
            get => _searchQuery;
            set
            {
                _searchQuery = value;
                OnPropertyChanged();
                OnPropertyChanged(nameof(FilteredApps));
            }
        }

        public IEnumerable<AppEntry> FilteredApps
        {
            get
            {
                if (string.IsNullOrWhiteSpace(_searchQuery)) return _apps;
                return _apps.Where(a => a.Name.Contains(_searchQuery, StringComparison.OrdinalIgnoreCase));
            }
        }

        public ICommand LaunchAppCommand { get; }
        public ICommand OpenTerminalCommand { get; }
        public ICommand OpenBrowserCommand { get; }
        public ICommand OpenExplorerCommand { get; }
        public ICommand OpenSettingsCommand { get; }

        public DashboardViewModel(IMediaService mediaService, IAppService appService, ISystemMonitorService systemMonitor)
        {
            _mediaService  = mediaService;
            _appService    = appService;
            _systemMonitor = systemMonitor;

            _mediaService.MediaChanged += (s, e) =>
                System.Windows.Application.Current.Dispatcher.Invoke(() => NowPlaying = e);
            NowPlaying = _mediaService.GetCurrentMedia();

            Apps = new ObservableCollection<AppEntry>();
            if (Apps.Count == 0) LoadAppsAsync();

            LaunchAppCommand  = new RelayCommand<AppEntry>(LaunchApp);
            OpenTerminalCommand = new RelayCommand(OpenTerminal);
            OpenBrowserCommand  = new RelayCommand(OpenBrowser);
            OpenExplorerCommand = new RelayCommand(OpenExplorer);
            OpenSettingsCommand = new RelayCommand(OpenSettings);

            // Clock timer
            var clockTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
            clockTimer.Tick += (s, e) => UpdateTime();
            clockTimer.Start();
            UpdateTime();

            // System stats — warm up on background thread, then poll every 2s
            System.Threading.Tasks.Task.Run(() => _systemMonitor.GetStats()); // warm-up
            var sysTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(2) };
            sysTimer.Tick += async (s, e) =>
            {
                var stats = await System.Threading.Tasks.Task.Run(() => _systemMonitor.GetStats());
                SystemStats = stats;
            };
            sysTimer.Start();
            UpdateSystemStats();
        }

        private void UpdateSystemStats()
        {
            System.Threading.Tasks.Task.Run(() =>
            {
                var stats = _systemMonitor.GetStats();
                System.Windows.Application.Current.Dispatcher.Invoke(() => SystemStats = stats);
            });
        }

        private async void LoadAppsAsync()
        {
            await System.Threading.Tasks.Task.Delay(400);
            if (Apps.Count > 0) return;

            var apps = await System.Threading.Tasks.Task.Run(() => _appService.GetInstalledApps());
            System.Windows.Application.Current.Dispatcher.Invoke(() =>
            {
                if (Apps.Count > 0) return;
                foreach (var app in apps) Apps.Add(app);
                OnPropertyChanged(nameof(FilteredApps));
            });
        }

        private void UpdateTime()
        {
            CurrentTime = DateTime.Now.ToString("HH:mm:ss");
            CurrentDate = DateTime.Now.ToString("dddd, MMMM d, yyyy");
        }

        public void LaunchApp(AppEntry? app) => _appService.LaunchApp(app);

        private void OpenTerminal()    => System.Diagnostics.Process.Start("cmd.exe");
        private void OpenBrowser()     => System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo("https://") { UseShellExecute = true });
        private void OpenExplorer()    => System.Diagnostics.Process.Start("explorer.exe");
        private void OpenSettings()    => System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo("ms-settings:") { UseShellExecute = true });

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }
}
