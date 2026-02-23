using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

namespace StartupDashboard.ViewModels
{
    public class WelcomeViewModel : INotifyPropertyChanged
    {
        private string _greeting = "";
        public string Greeting
        {
            get => _greeting;
            set { _greeting = value; OnPropertyChanged(); }
        }

        public event Action? NavigationRequested;

        public WelcomeViewModel()
        {
            Greeting = BuildGreeting();
            StartWelcomeSequence();
        }

        private static string BuildGreeting()
        {
            int hour = DateTime.Now.Hour;
            return hour switch
            {
                >= 5 and < 12  => "Good morning.",
                >= 12 and < 17 => "Good afternoon.",
                >= 17 and < 21 => "Good evening.",
                _              => "Good night."
            };
        }

        private async void StartWelcomeSequence()
        {
            await Task.Delay(1500);
            NavigationRequested?.Invoke();
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }
}
