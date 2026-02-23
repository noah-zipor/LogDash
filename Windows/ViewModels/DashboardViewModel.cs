using System;
using System.Collections.Generic;
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
        private ObservableCollection<AppEntry> _apps;
        private SystemStats _systemStats = new SystemStats();

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

        public MediaInfo NowPlaying
        {
            get => _nowPlaying;
            set { _nowPlaying = value; OnPropertyChanged(); }
        }

        public ObservableCollection<AppEntry> Apps
        {
            get => _apps;
            set { _apps = value; OnPropertyChanged(); }
        }

        public SystemStats SystemStats
        {
            get => _systemStats;
            set { _systemStats = value; OnPropertyChanged(); }
        }

        public ICommand LaunchAppCommand { get; }

        public DashboardViewModel(IMediaService mediaService, IAppService appService, ISystemMonitorService systemMonitor)
        {
            _mediaService = mediaService;
            _appService = appService;
            _systemMonitor = systemMonitor;

            _mediaService.MediaChanged += (s, e) =>
            {
                System.Windows.Application.Current.Dispatcher.Invoke(() => NowPlaying = e);
            };
            NowPlaying = _mediaService.GetCurrentMedia();

            Apps = new ObservableCollection<AppEntry>();
            // LoadAppsAsync will be called only if Apps is empty
            if (Apps.Count == 0)
            {
                LoadAppsAsync();
            }

            LaunchAppCommand = new RelayCommand<AppEntry>(LaunchApp);

            var timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
            timer.Tick += (s, e) => UpdateTime();
            timer.Start();
            UpdateTime();

            var sysTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(2) };
            sysTimer.Tick += (s, e) => UpdateSystemStats();
            sysTimer.Start();
            UpdateSystemStats();
        }

        private void UpdateSystemStats()
        {
            SystemStats = _systemMonitor.GetStats();
        }

        private async void LoadAppsAsync()
        {
            // Avoid double loading if already pre-fetched
            await System.Threading.Tasks.Task.Delay(500);
            if (Apps.Count > 0) return;

            var apps = await System.Threading.Tasks.Task.Run(() => _appService.GetInstalledApps());
            System.Windows.Application.Current.Dispatcher.Invoke(() =>
            {
                if (Apps.Count > 0) return; // Final check
                foreach (var app in apps)
                {
                    Apps.Add(app);
                }
            });
        }

        private void UpdateTime()
        {
            CurrentTime = DateTime.Now.ToString("HH:mm:ss");
            CurrentDate = DateTime.Now.ToString("dddd, MMMM d, yyyy");
        }

        public void LaunchApp(AppEntry? app)
        {
            _appService.LaunchApp(app);
            // Optional: Minimize dashboard
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }
}
