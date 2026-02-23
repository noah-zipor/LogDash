using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using StartupDashboard.Core;
using StartupDashboard.Services;
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
        private int _attemptsRemaining;
        private bool _showAttemptsWarning;

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

        public int AttemptsRemaining
        {
            get => _attemptsRemaining;
            set { _attemptsRemaining = value; OnPropertyChanged(); OnPropertyChanged(nameof(AttemptsWarningText)); OnPropertyChanged(nameof(ShowAttemptsWarning)); }
        }

        public bool ShowAttemptsWarning => AttemptsRemaining < 3 && AttemptsRemaining > 0;
        public string AttemptsWarningText => $"{AttemptsRemaining} attempt{(AttemptsRemaining == 1 ? "" : "s")} remaining before lockout";

        public ICommand LoginCommand { get; }
        public ICommand ExitCommand { get; }

        public event Action? LoginSuccess;

        public LoginViewModel(IAuthService authService, ISecurityPolicyService securityPolicy)
        {
            _authService = authService;
            _securityPolicy = securityPolicy;
            _attemptsRemaining = securityPolicy.AttemptsRemaining;
            LoginCommand = new RelayCommand(ExecuteLogin);
            ExitCommand  = new RelayCommand(ExecuteExit);
        }

        private void ExecuteLogin()
        {
            // Reset error so shake triggers again on new attempt
            IsErrorVisible = false;

            if (_securityPolicy.IsLockedOut)
            {
                int mins = (int)Math.Ceiling((_securityPolicy.LockoutExpiry - DateTime.Now).TotalMinutes);
                ErrorMessage   = $"Account locked. Try again in {mins} minute{(mins == 1 ? "" : "s")}.";
                IsErrorVisible = true;
                return;
            }

            if (_authService.Authenticate(Password))
            {
                _securityPolicy.ResetAttempts();
                Password = ""; // Clear from memory
                LoginSuccess?.Invoke();
            }
            else
            {
                _securityPolicy.RecordFailedAttempt();
                AttemptsRemaining = _securityPolicy.AttemptsRemaining;

                if (_securityPolicy.IsLockedOut)
                {
                    ErrorMessage = "Too many attempts. Account locked for 15 minutes.";
                }
                else
                {
                    ErrorMessage = AttemptsRemaining > 0
                        ? $"Incorrect password. {AttemptsRemaining} attempt{(AttemptsRemaining == 1 ? "" : "s")} remaining."
                        : "Incorrect password.";
                }
                IsErrorVisible = true;
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
