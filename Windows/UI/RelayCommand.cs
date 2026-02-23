using System;
using System.Windows.Input;

namespace StartupDashboard.UI
{
    public class RelayCommand : ICommand
    {
        private readonly Action _execute;
        public RelayCommand(Action execute) => _execute = execute;
        public bool CanExecute(object? parameter) => true;
        public void Execute(object? parameter) => _execute();
        public event EventHandler? CanExecuteChanged;
    }

    public class RelayCommand<T> : ICommand
    {
        private readonly Action<T> _execute;
        public RelayCommand(Action<T> execute) => _execute = execute;
        public bool CanExecute(object? parameter) => true;
        public void Execute(object? parameter)
        {
            if (parameter is T value)
            {
                _execute(value);
            }
            else if (parameter == null && default(T) == null)
            {
                _execute(default!);
            }
        }
        public event EventHandler? CanExecuteChanged;
    }
}
