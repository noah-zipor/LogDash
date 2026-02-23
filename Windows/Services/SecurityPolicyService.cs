using System;
using System.Security;

namespace StartupDashboard.Services
{
    public interface ISecurityPolicyService
    {
        bool IsLockedOut { get; }
        void RecordFailedAttempt();
        void ResetAttempts();
        void ClearSensitiveData(SecureString sensitiveData);
    }

    public class SecurityPolicyService : ISecurityPolicyService
    {
        private int _failedAttempts = 0;
        private const int MaxAttempts = 5;
        private DateTime _lockoutExpiry = DateTime.MinValue;

        public bool IsLockedOut => DateTime.Now < _lockoutExpiry;

        public void RecordFailedAttempt()
        {
            _failedAttempts++;
            if (_failedAttempts >= MaxAttempts)
            {
                _lockoutExpiry = DateTime.Now.AddMinutes(15);
            }
        }

        public void ResetAttempts()
        {
            _failedAttempts = 0;
            _lockoutExpiry = DateTime.MinValue;
        }

        public void ClearSensitiveData(SecureString sensitiveData)
        {
            sensitiveData?.Dispose();
        }
    }
}
