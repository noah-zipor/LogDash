using System;
using System.Threading.Tasks;
using Windows.Media.Control;
using Windows.Storage.Streams;
using StartupDashboard.Core;

namespace StartupDashboard.Services
{
    public class WindowsMediaService : IMediaService
    {
        private GlobalSystemMediaTransportControlsSessionManager _sessionManager;

        public event EventHandler<MediaInfo> MediaChanged;

        public WindowsMediaService()
        {
            _ = InitializeAsync();
        }

        private MediaInfo _lastInfo;
        private GlobalSystemMediaTransportControlsSession _currentSession;

        private async Task InitializeAsync()
        {
            _sessionManager = await GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
            _sessionManager.CurrentSessionChanged += OnCurrentSessionChanged;
            UpdateCurrentSession();
        }

        private void OnCurrentSessionChanged(GlobalSystemMediaTransportControlsSessionManager sender, CurrentSessionChangedEventArgs args)
        {
            UpdateCurrentSession();
        }

        private void UpdateCurrentSession()
        {
            if (_currentSession != null)
            {
                _currentSession.MediaPropertiesChanged -= OnMediaPropertiesChanged;
                _currentSession.PlaybackInfoChanged -= OnPlaybackInfoChanged;
            }

            _currentSession = _sessionManager.GetCurrentSession();

            if (_currentSession != null)
            {
                _currentSession.MediaPropertiesChanged += OnMediaPropertiesChanged;
                _currentSession.PlaybackInfoChanged += OnPlaybackInfoChanged;
            }

            UpdateMediaInfo();
        }

        private void OnPlaybackInfoChanged(GlobalSystemMediaTransportControlsSession sender, PlaybackInfoChangedEventArgs args)
        {
            UpdateMediaInfo();
        }

        private void OnMediaPropertiesChanged(GlobalSystemMediaTransportControlsSession sender, MediaPropertiesChangedEventArgs args)
        {
            UpdateMediaInfo();
        }

        private async void UpdateMediaInfo()
        {
            if (_sessionManager == null) return;

            var session = _sessionManager.GetCurrentSession();
            MediaInfo info;

            if (session != null)
            {
                try
                {
                    var mediaProperties = await session.TryGetMediaPropertiesAsync();
                    var playbackInfo = session.GetPlaybackInfo();

                    if (mediaProperties == null || playbackInfo == null)
                    {
                        info = GetFallbackInfo();
                    }
                    else
                    {
                        info = new MediaInfo
                        {
                            Title = !string.IsNullOrEmpty(mediaProperties.Title) ? mediaProperties.Title : "Unknown Title",
                            Artist = !string.IsNullOrEmpty(mediaProperties.Artist) ? mediaProperties.Artist : "Unknown Artist",
                            IsPlaying = playbackInfo.PlaybackStatus == GlobalSystemMediaTransportControlsSessionPlaybackStatus.Playing
                        };

                        if (mediaProperties.Thumbnail != null)
                        {
                            try
                            {
                                using (var stream = await mediaProperties.Thumbnail.OpenReadAsync())
                                {
                                    var buffer = new byte[stream.Size];
                                    using (var reader = new DataReader(stream))
                                    {
                                        await reader.LoadAsync((uint)stream.Size);
                                        reader.ReadBytes(buffer);
                                    }
                                    info.AlbumArt = buffer;
                                }
                            }
                            catch { /* Ignore thumbnail errors */ }
                        }
                    }
                }
                catch
                {
                    info = GetFallbackInfo();
                }
            }
            else
            {
                info = GetFallbackInfo();
            }

            _lastInfo = info;
            MediaChanged?.Invoke(this, info);
        }

        private MediaInfo GetFallbackInfo()
        {
            return new MediaInfo
            {
                Title = "Nothing Playing",
                Artist = "Start some music",
                IsPlaying = false,
                AlbumArt = null
            };
        }

        public MediaInfo GetCurrentMedia()
        {
            return _lastInfo ?? GetFallbackInfo();
        }
    }
}
