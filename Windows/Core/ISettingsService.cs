namespace StartupDashboard.Core
{
    public interface ISettingsService
    {
        void SetString(string key, string value);
        string GetString(string key, string defaultValue = "");
        void SetBool(string key, bool value);
        bool GetBool(string key, bool defaultValue = false);
    }
}
