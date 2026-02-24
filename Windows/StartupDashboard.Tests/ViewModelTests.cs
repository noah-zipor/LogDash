using System;
using Xunit;
using StartupDashboard.ViewModels;
using StartupDashboard.Core;

namespace StartupDashboard.Tests
{
    public class ViewModelTests
    {
        [Fact]
        public void LoginViewModel_ErrorVisible_OnFailedAuth()
        {
            var mockAuth = new MockAuthService(false);
            var vm = new LoginViewModel(mockAuth);
            vm.Password = "wrong";
            vm.LoginCommand.Execute(null);

            Assert.True(vm.IsErrorVisible);
            Assert.Equal("Incorrect Password", vm.ErrorMessage);
        }

        private class MockAuthService : IAuthService
        {
            private bool _success;
            public MockAuthService(bool success) => _success = success;
            public bool Authenticate(string password) => _success;
            public void SetPassword(string p) { }
            public bool IsPasswordSet() => true;
        }
    }
}
