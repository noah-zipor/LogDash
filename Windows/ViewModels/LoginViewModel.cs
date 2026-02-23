using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using StartupDashboard.Core;
using StartupDashboard.UI;

namespace StartupDashboard.ViewModels
{
    public class LoginViewModel : INotifyPropertyChanged
    {
        private readonly IAuthService _authService;
        private readonly ISecurityPolicyService _securityPolicy;
        private string _password = "";
        private string _errorMessage = "";
        private bool _isErrorVisible;

        public string Password
        {
            get => _password;
            set { _password = value; OnPropertyChanged(); }
        }

        public string ErrorMessage
        {
            get => _errorMessage;
            set { _errorMessage = value; OnPropertyChanged(); }
        }

        public bool IsErrorVisible
        {
            get => _isErrorVisible;
            set { _isErrorVisible = value; OnPropertyChanged(); }
        }

        public ICommand LoginCommand { get; }
        public ICommand ExitCommand { get; }

        public event Action? LoginSuccess;

        public LoginViewModel(IAuthService authService, ISecurityPolicyService securityPolicy)
        {
            _authService = authService;
            _securityPolicy = securityPolicy;
            LoginCommand = new RelayCommand(ExecuteLogin);
            ExitCommand = new RelayCommand(ExecuteExit);
        }

        private void ExecuteLogin()
        {
            if (_securityPolicy.IsLockedOut)
            {
                ErrorMessage = "Account locked. Please try again in 15 minutes.";
                IsErrorVisible = true;
                return;
            }

            if (_authService.Authenticate(Password))
            {
                _securityPolicy.ResetAttempts();
                LoginSuccess?.Invoke();
            }
            else
            {
                _securityPolicy.RecordFailedAttempt();
                ErrorMessage = "Incorrect Password";
                IsErrorVisible = true;
                // Trigger shake animation in View
            }
        }

        private void ExecuteExit()
        {
            System.Windows.Application.Current.Shutdown();
        }

        public event PropertyChangedEventHandler? PropertyChanged;
        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }

}
