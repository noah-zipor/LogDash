using System.Windows;
using StartupDashboard.Services;
using StartupDashboard.ViewModels;

namespace StartupDashboard
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            // Manual DI / Composition Root
            var authService = new WindowsSecurityService();
            var mediaService = new WindowsMediaService();
            var appService = new WindowsAppService();
            var securityPolicy = new SecurityPolicyService();
            var systemMonitor = new WindowsSystemMonitorService();

            var mainViewModel = new MainViewModel(authService, mediaService, appService, securityPolicy, systemMonitor);

            var mainWindow = new MainWindow();
            mainWindow.DataContext = mainViewModel;
            mainWindow.Show();
        }
    }
}
