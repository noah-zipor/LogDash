using Windows.Security.Credentials;
using StartupDashboard.Core;
using System.Linq;

namespace StartupDashboard.Services
{
    public class WindowsSecurityService : IAuthService
    {
        private const string ResourceName = "StartupDashboard";
        private const string UserName = "Noah"; // Default user as per requirements
        private readonly PasswordVault _vault = new PasswordVault();

        public bool Authenticate(string password)
        {
            try
            {
                var credential = _vault.Retrieve(ResourceName, UserName);
                return credential.Password == password;
            }
            catch
            {
                return false;
            }
        }

        public void SetPassword(string newPassword)
        {
            try
            {
                var existing = _vault.FindAllByResource(ResourceName).FirstOrDefault();
                if (existing != null) _vault.Remove(existing);
            }
            catch { }

            _vault.Add(new PasswordCredential(ResourceName, UserName, newPassword));
        }

        public bool IsPasswordSet()
        {
            try
            {
                return _vault.FindAllByResource(ResourceName).Any();
            }
            catch
            {
                return false;
            }
        }
    }
}
