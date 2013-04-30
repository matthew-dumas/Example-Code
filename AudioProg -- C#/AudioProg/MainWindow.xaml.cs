using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
//using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Media;
using System.Windows.Forms;
using Utilities; 


namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {

            InitializeComponent();
        }

        private Boolean play = true;
        private Boolean pause = true;
        private globalKeyboardHook gkh = new globalKeyboardHook();

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            PlayStop();
        }

        private void PlayStop()
        {
            if (play)
            {
                mediaElement1.Position = TimeSpan.Zero;
                mediaElement1.Play();
                button1.Content = "Stop";
            }
            else
            {
                button1.Content = "Play";
                mediaElement1.Stop();
            }
            play = !play;
        }

       
        private void button2_Click(object sender, RoutedEventArgs e)
        {
            PlayPause();
        }

        private void PlayPause()
        {
            if (pause)
            {
                mediaElement1.Pause();
                button2.Content = "Resume";
            }
            else
            {
                mediaElement1.Play();
                button2.Content = "Pause";
            }
            pause = !pause;
        }

        private void button3_Click(object sender, RoutedEventArgs e)
        {
            FastForward();
        }

        private void FastForward()
        {
            mediaElement1.Pause();
            mediaElement1.SpeedRatio = 1.25;
            mediaElement1.Play();
        }

        private void button4_Click(object sender, RoutedEventArgs e)
        {
            SlowDown();

        }

        private void SlowDown()
        {
            mediaElement1.Pause();
            mediaElement1.SpeedRatio = -1;
            mediaElement1.Play();
        }

        private void button5_Click(object sender, RoutedEventArgs e)
        {
            Minus3();
        }

        private void Minus3()
        {
            TimeSpan ts = new TimeSpan(0, 0, 3);
            mediaElement1.Position = mediaElement1.Position - ts;
        }

        private void button6_Click(object sender, RoutedEventArgs e)
        {
            Plus3();
        }

        private void Plus3()
        {
            TimeSpan ts = new TimeSpan(0, 0, 3);
            mediaElement1.Position = mediaElement1.Position + ts;
        }

        private void button3_Click_1(object sender, RoutedEventArgs e)
        {
            Minus10();
        }

        private void Minus10()
        {
            TimeSpan ts = new TimeSpan(0, 0, 10);
            mediaElement1.Position = mediaElement1.Position - ts;
        }

        private void button4_Click_1(object sender, RoutedEventArgs e)
        {
            Plus10();
        }

        private void Plus10()
        {
            TimeSpan ts = new TimeSpan(0, 0, 10);
            mediaElement1.Position = mediaElement1.Position + ts;
        }

        private void listBox1_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            mediaElement1.LoadedBehavior = MediaState.Manual;
            mediaElement1.Source = new System.Uri(fileList.SelectedItem.ToString());
        }

       
        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            
            gkh.HookedKeys.Add(Keys.PageDown);  // forward 3 seconds
            gkh.HookedKeys.Add(Keys.PageUp);    // back 3 seconds

            gkh.HookedKeys.Add(Keys.Play);            // play/pause
            gkh.HookedKeys.Add(Keys.MediaPlayPause);  // play / pause
            gkh.HookedKeys.Add(Keys.F2);              // Play/Pause

            gkh.HookedKeys.Add(Keys.MediaStop);       // stop 
            gkh.HookedKeys.Add(Keys.F3);              // stop

            gkh.HookedKeys.Add(Keys.F7);              // -10
            gkh.HookedKeys.Add(Keys.F8);              // +10


            gkh.KeyDown += new KeyEventHandler(gkh_KeyDown);

            GC.KeepAlive(gkh);
        }

        void gkh_KeyDown(object sender, KeyEventArgs e)
        {
            
            switch (e.KeyCode)
            {
                case Keys.PageDown:
                    Minus3();
                    e.Handled = true;
                    break;

                case Keys.PageUp:
                    Plus3();
                    e.Handled = true;
                    break;

                case Keys.F2:
                    PlayPause();
                    e.Handled = true;
                    break;

                case Keys.F3:
                    PlayStop();
                    e.Handled = true;
                    break;
             
                case Keys.Play:
                    PlayPause();
                    e.Handled = true;
                    break;

                case Keys.MediaPlayPause:
                    PlayPause();
                    e.Handled = true;
                    break;

                case Keys.MediaStop:
                    PlayStop();
                    e.Handled = true;
                    break;

                case Keys.F7:
                    Minus10();
                    e.Handled = true;
                    break;

                case Keys.F8:
                    
                    Plus10();
                    e.Handled = true;
                    break;
                default:
                    e.Handled = false;
                    break;
            }

            
        }

        private void button7_Click(object sender, RoutedEventArgs e)
        {
            List<string> alFiles = new List<string>();
            var dialog = new FolderBrowserDialog();
            if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                alFiles.AddRange(System.IO.Directory.GetFiles(dialog.SelectedPath, "*.mp3"));
                alFiles.AddRange(System.IO.Directory.GetFiles(dialog.SelectedPath, "*.wav"));
                alFiles.AddRange(System.IO.Directory.GetFiles(dialog.SelectedPath, "*.3gp"));
                alFiles.AddRange(System.IO.Directory.GetFiles(dialog.SelectedPath, "*.m4a"));
                alFiles.AddRange(System.IO.Directory.GetFiles(dialog.SelectedPath, "*.wma"));
                
                foreach (var fil in alFiles) {
                    fileList.Items.Add(fil);
                }
            }
        } 
    }

}