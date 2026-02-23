using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows.Input;

namespace StartupDashboard.ViewModels
{
    public class WelcomeViewModel : INotifyPropertyChanged
    {
        private string _greeting = "Hello Noah";
        public string Greeting
        {
            get => _greeting;
            set { _greeting = value; OnPropertyChanged(); }
        }

        public event Action? NavigationRequested;

        public WelcomeViewModel()
        {
            StartWelcomeSequence();
        }

        private async void StartWelcomeSequence()
        {
            // Reduced hold time for a faster, snappier feel
            await Task.Delay(1500);
            NavigationRequested?.Invoke();
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }
}
