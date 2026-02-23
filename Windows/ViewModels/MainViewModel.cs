using System.ComponentModel;
using System.Runtime.CompilerServices;
using StartupDashboard.Core;

namespace StartupDashboard.ViewModels
{
    public class MainViewModel : INotifyPropertyChanged
    {
        private object? _currentViewModel;
        private readonly IAuthService _authService;
        private readonly IMediaService _mediaService;
        private readonly IAppService _appService;
        private readonly ISecurityPolicyService _securityPolicy;
        private readonly ISystemMonitorService _systemMonitor;
        private System.Collections.Generic.IEnumerable<AppEntry>? _cachedApps;

        public object CurrentViewModel
        {
            get => _currentViewModel;
            set { _currentViewModel = value; OnPropertyChanged(); }
        }

        public MainViewModel(IAuthService authService, IMediaService mediaService, IAppService appService, ISecurityPolicyService securityPolicy, ISystemMonitorService systemMonitor)
        {
            _authService = authService;
            _mediaService = mediaService;
            _appService = appService;
            _securityPolicy = securityPolicy;
            _systemMonitor = systemMonitor;

            NavigateToWelcome();
            PreFetchApps();
        }

        private async void PreFetchApps()
        {
            _cachedApps = await Task.Run(() => _appService.GetInstalledApps());
        }

        private void NavigateToWelcome()
        {
            var vm = new WelcomeViewModel();
            vm.NavigationRequested += () =>
            {
                if (_authService.IsPasswordSet())
                {
                    NavigateToLogin();
                }
                else
                {
                    NavigateToSetup();
                }
            };
            CurrentViewModel = vm;
        }

        private void NavigateToSetup()
        {
            var vm = new SetupViewModel(_authService, _securityPolicy);
            vm.SetupSuccess += () => NavigateToDashboard();
            CurrentViewModel = vm;
        }

        private void NavigateToLogin()
        {
            var vm = new LoginViewModel(_authService, _securityPolicy);
            vm.LoginSuccess += () => NavigateToDashboard();
            CurrentViewModel = vm;
        }

        private void NavigateToDashboard()
        {
            var vm = new DashboardViewModel(_mediaService, _appService, _systemMonitor);
            if (_cachedApps != null)
            {
                foreach (var app in _cachedApps)
                {
                    vm.Apps.Add(app);
                }
            }
            CurrentViewModel = vm;
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }
}
