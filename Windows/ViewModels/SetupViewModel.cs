using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using StartupDashboard.Core;
using StartupDashboard.UI;

namespace StartupDashboard.ViewModels
{
    public class SetupViewModel : INotifyPropertyChanged
    {
        private readonly IAuthService _authService;
        private readonly ISecurityPolicyService _securityPolicy;
        private string _password = "";
        private string _confirmPassword = "";
        private string _errorMessage = "";
        private bool _isErrorVisible;

        public string Password
        {
            get => _password;
            set { _password = value; OnPropertyChanged(); }
        }

        public string ConfirmPassword
        {
            get => _confirmPassword;
            set { _confirmPassword = value; OnPropertyChanged(); }
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

        public ICommand SetPasswordCommand { get; }
        public ICommand ExitCommand { get; }

        public event Action? SetupSuccess;

        public SetupViewModel(IAuthService authService, ISecurityPolicyService securityPolicy)
        {
            _authService = authService;
            _securityPolicy = securityPolicy;
            SetPasswordCommand = new RelayCommand(ExecuteSetup);
            ExitCommand = new RelayCommand(ExecuteExit);
        }

        private void ExecuteSetup()
        {
            if (string.IsNullOrWhiteSpace(Password))
            {
                ErrorMessage = "Password cannot be empty";
                IsErrorVisible = true;
                return;
            }

            if (Password != ConfirmPassword)
            {
                ErrorMessage = "Passwords do not match";
                IsErrorVisible = true;
                return;
            }

            _authService.SetPassword(Password);
            SetupSuccess?.Invoke();
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
