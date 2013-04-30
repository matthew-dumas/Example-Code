using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Net;
using System.Text.RegularExpressions;
using HtmlAgilityPack;
using System.Collections.ObjectModel;


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
        public class project
        {
            public string m_title;
            public string m_phase1;
            public string m_phase2;
            public string m_phase3;
            public string m_techArea;
            public string m_acqProgr;
            public string m_objective;
            public string m_desc;
            public string m_keywords;
            public string m_refs;
            public string m_id;
            public string m_commerc;

            public project(string title, string phase1, string phase2, string phase3, string tech, string acq, string desc, string key, string refs, string obj, string id, string commerc)
            {

                m_title = title;
                m_phase1 = phase1;
                m_phase2 = phase2;
                m_phase3 = phase3;
                m_techArea = tech;
                m_acqProgr = acq;
                m_objective = obj;
                m_desc = desc;
                m_keywords = key;
                m_refs = refs;
                m_id = id;
                m_commerc = commerc;
            }
        }

        public class SBIRInfo
        {
            public string m_url;
            public string m_title;
            public string m_solicURL;
            public Dictionary<string, string> m_agencyURLs;
            public Dictionary<string, HtmlDocument> m_agencyDocs;
            public List<project> m_projs;
            public string m_year;
            public string m_offering;

            public SBIRInfo(string title, string url)
            {
                m_url = url;
                m_title = title;
                m_agencyURLs = new Dictionary<string, string>();
                m_agencyDocs = new Dictionary<string, HtmlDocument>();
                m_projs = new List<project>();
            }
        }

        private Boolean loading = false;
        
        public string baseURL = "http://www.acq.osd.mil/osbp/sbir/solicitations/";
        public ObservableCollection<SBIRInfo> Solicitations = new ObservableCollection<SBIRInfo>();

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            HtmlWeb htmlWeb = new HtmlWeb();
            HtmlAgilityPack.HtmlDocument document = htmlWeb.Load(baseURL + "archives.shtml");

            HtmlNode mainNode = document.GetElementbyId("mainCol");

            if (mainNode != null)
            {

                IEnumerable<HtmlNode> allLinks = mainNode.Descendants("a");
                foreach (HtmlNode link in allLinks)
                {
                    string pHref = WebUtility.HtmlDecode(link.Attributes["href"].Value.ToString());
                    string ptitle = WebUtility.HtmlDecode(link.Attributes["title"].Value.ToString());
                    if (link.Attributes.Contains("href")  && link.Attributes.Contains("title"))
                    {
                        Solicitations.Add(new SBIRInfo(ptitle,pHref));
                        SolicitationHistory.Items.Add(ptitle);
                    }
                }

            }

            document = null;
            htmlWeb = null; 

        }

        private void SolicitationHistory_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            loading = true;
            solicitationList.SelectedIndex = -1;
            solicitationList.Items.Clear();
            projectsList.Items.Clear();

            string selected = WebUtility.HtmlDecode((string)SolicitationHistory.SelectedItem);
            if (selected != null)
            {
                string pattern = "(\\d\\d\\d\\d)\\.(.)";
                Regex reg = new Regex(pattern);
                Match m = reg.Match(selected);
                string year = m.Groups[1].ToString();
                string off = m.Groups[2].ToString();
                WebClient client = new WebClient();
                foreach (SBIRInfo Solic in Solicitations)
                {
                    if (Solic.m_title == selected)
                    {
                        Solic.m_year = year;
                        Solic.m_offering = off;

                        HtmlWeb htmlWeb = new HtmlWeb();
                        HtmlAgilityPack.HtmlDocument document = htmlWeb.Load(baseURL + Solic.m_url);

                        HtmlNode mainNode = document.GetElementbyId("mainCol");
                        
                        if (mainNode != null)
                        {
                            IEnumerable<HtmlNode> allLinks = mainNode.Descendants("a");
                            foreach (HtmlNode link in allLinks)
                            {
                                if (link.Attributes.Contains("href") && link.Attributes.Contains("title"))
                                {
                                    if (link.Attributes["title"].Value.Contains("[HTML]") && !link.Attributes["title"].Value.Contains("Solicitation"))
                                    {
                                        Solic.m_solicURL = WebUtility.HtmlDecode(baseURL + Solic.m_url);
                                        Solic.m_agencyURLs[WebUtility.HtmlDecode(link.Attributes["title"].Value.ToString().Trim())] = WebUtility.HtmlDecode(link.Attributes["href"].Value.ToString().Trim());
                                        string url = baseURL + Solic.m_url;
                                        url = url.Replace("index.shtml",WebUtility.HtmlDecode(link.Attributes["href"].Value.ToString().Trim()));

                                        try
                                        {
                                            client.DownloadFile(url, @"C:\!\SBIR\" + WebUtility.HtmlDecode(link.Attributes["href"].Value.ToString().Trim()));
                                        }
                                        catch (Exception ex)
                                        {

                                        }

                                        Solic.m_agencyDocs[WebUtility.HtmlDecode(link.Attributes["title"].Value.ToString().Trim())] = null;
                                        solicitationList.Items.Add(WebUtility.HtmlDecode(link.Attributes["title"].Value.ToString()));
                                    }
                                }
                            }
                        }
                        document = null;
                        mainNode = null;
                        break;
                    }
                }
            }
            loading = false;
        }

        private void solicitationList_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!loading)
            {
                projectsList.Items.Clear();
                string selected = (string)SolicitationHistory.SelectedItem;
                string agency = (string)solicitationList.SelectedItem;
                if (agency != null)
                {
                    foreach (SBIRInfo Solic in Solicitations)
                    {
                        if (Solic.m_title == selected)
                        {
                            HtmlWeb htmlWeb = new HtmlWeb();
                            HtmlDocument document = new HtmlDocument();
                            string url = baseURL + Solic.m_url;
                            if (Solic.m_agencyDocs[agency] == null)
                            {
                                url = url.Replace("index.shtml", Solic.m_agencyURLs[agency]);
                                document = htmlWeb.Load(url);
                                Solic.m_agencyDocs[agency] = document;
                            }
                            else
                            {
                                document = Solic.m_agencyDocs[agency];
                            }
                            Boolean flag = false;
                            string sect = "";
                            string title = "";
                            string desc = "";
                            string phase1 = "";
                            string phase2 = "";
                            string phase3 = "";
                            string tech = "";
                            string acq = "";
                            string keys = "";
                            string id = "";
                            string obj = "";
                            string refs = "";
                            string commerc = "";
                            Boolean dump = false;
                            string parsed = "";
                            Regex regp = new Regex("Topic\\s+?Descriptions");
                            Regex reg2 = new Regex("RESEARCH\\s+?TOPICS");
                            foreach (HtmlNode node in document.DocumentNode.SelectNodes("//body//p//span"))
                            {
                                parsed = WebUtility.HtmlDecode(node.InnerText.Replace("\r\n"," ").Trim());
                                
                                if (regp.IsMatch(parsed) || reg2.IsMatch(parsed))
                                {
                                    flag = true;
                                    continue;
                                }
                                if (flag)
                                {
                                    parsed.Replace("<", "&LT;");
                                    parsed.Replace(">", "&GT;"); 
                                    if (parsed.Contains("TITLE:"))
                                    {

                                        string pattern = "(\\w+?-?\\w+-?[\\w|\\d]+).+?TITLE:(.+)";
                                        parsed = parsed.Replace("\n", " ");
                                        Regex regex = new Regex(pattern);
                                        Match m = regex.Match(parsed);

                                        if (m.Captures.Count >= 1)
                                        {
                                            id = m.Groups[1].Value;
                                            title = m.Groups[2].Value;
                                        }

                                    }
                                    else if (parsed.Contains("TECHNOLOGY AREAS"))
                                    {
                                        tech = parsed.Replace("TECHNOLOGY AREAS", "");
                                    }
                                    else if (parsed.Contains("ACQUISITION PROGRAM"))
                                    {
                                        acq = parsed.Replace("ACQUISITION PROGRAM", "");
                                    }
                                    else if (parsed.Contains("OBJECTIVE"))
                                    {
                                        sect = "obj";
                                    }
                                    else if (parsed.Contains("DESCRIPTION"))
                                    {
                                        sect = "desc";
                                    }
                                    else if (parsed.Contains("PHASE I"))
                                    {
                                        phase1 = parsed.Replace("PHASE I", "");
                                    }
                                    else if (parsed.Contains("PHASE II"))
                                    {
                                        phase2 = parsed.Replace("PHASE II", "");
                                    }
                                    else if (parsed.Contains("PHASE III"))
                                    {
                                        phase3 = parsed.Replace("PHASE III", "");
                                    }
                                    else if (parsed.Contains("REFERENCES"))
                                    {
                                        sect = "refs";
                                    }
                                    else if (parsed.Contains("KEYWORDS"))
                                    {
                                        keys = parsed.Replace("KEYWORDS", "");
                                        dump = true;
                                    }
                                    else if (parsed.Contains("COMMERCIALIZATION"))
                                    {
                                        commerc = parsed.Replace("COMMERCIALIZATION", "");
                                        dump = true;
                                    }
                                    else
                                    {
                                        string a = parsed;
                                    }

                                    if (sect == "obj")
                                    {
                                        obj += parsed.Replace("OBJECTIVE", "");
                                    }
                                    else if (sect == "refs")
                                    {
                                        refs += parsed.Replace("REFERENCES", "");
                                    }
                                    else if (sect == "desc")
                                    {
                                        desc += parsed.Replace("DESCRIPTION", "");
                                    }



                                }
                                if (dump)
                                {
                                    Solic.m_projs.Add(new project(title, phase1, phase2, phase3, tech, acq, desc, keys, refs, obj, id, commerc));
                                    projectsList.Items.Add(id);
                                    dump = false;
                                    sect = "";
                                    title = "";
                                    desc = "";
                                    phase1 = "";
                                    phase2 = "";
                                    phase3 = "";
                                    tech = "";
                                    acq = "";
                                    keys = "";
                                    id = "";
                                    obj = "";
                                    refs = "";
                                    commerc = "";
                                    parsed = "";
                                }
                            }

                            document = null; 
                        }
                    }
                }
            }

        }

        private void button2_Click(object sender, RoutedEventArgs e)
        {
            /*var items = SolicitationHistory.SelectedItems;
            List<string> chosen = new List<string>();
            foreach (var item in items)
            {
                chosen.Add((string)item);
            }
            SolicitationHistory.SelectedIndex = -1;
            */
            foreach (string a in SolicitationHistory.Items) {
                SolicitationHistory.SelectedItem = a;
              /*  foreach (string b in solicitationList.Items)
                {
                    solicitationList.SelectedItem = b; 
                }*/
            }
            /*
            string output = "<SBIRDAT>\n"; 
            foreach (var solic in Solicitations)
            {
                output += "\t<solicitation>\n";

                output += "\t\t<solictitle>\n";
                output += "\t\t\t" + solic.m_title + "\n";
                output += "\t\t</solictitle>\n";

                output += "\t\t<year>\n";
                output += "\t\t\t" + solic.m_year + "\n";
                output += "\t\t</year>\n";

                output += "\t\t<offering>\n";
                output += "\t\t\t" + solic.m_offering + "\n";
                output += "\t\t</offering>\n";

                output += "\t\t<mainurl>\n";
                output += "\t\t\t" + solic.m_url + "\n";
                output += "\t\t</mainurl>\n";

                output += "\t\t<solicurl>\n";
                output += "\t\t\t" + solic.m_solicURL + "\n";
                output += "\t\t</solicurl>\n";


                output += "\t\t<mainurl>\n";
                output += "\t\t\t" + solic.m_url + "\n";
                output += "\t\t</mainurl>\n";


                output += "\t\t<agencies>\n";
                foreach (var kvp in solic.m_agencyURLs)
                {
                    output += "\t\t\t<agency>\n";
                    output += "\t\t\t\t" + kvp.Key + "\n";
                    output += "\t\t\t</agency>\n";
                    output += "\t\t\t<agencyurl>\n";
                    output += "\t\t\t\t" + kvp.Value + "\n";
                    output += "\t\t\t</agencyurl>\n";
                }
                output += "\t\t</agencies>\n";

                output += "\t\t<RFP>\n";
                foreach (var proj in solic.m_projs)
                {
                    output += "\t\t\t<topic>\n";
                    output += "\t\t\t\t<id>\n";
                    output += "\t\t\t\t\t" + proj.m_id + "\n";
                    output += "\t\t\t\t</id>\n";
                    output += "\t\t\t\t<title>\n";
                    output += "\t\t\t\t\t" + proj.m_title + "\n";
                    output += "\t\t\t\t</title>\n";

                    output += "\t\t\t\t<program>\n";
                    output += "\t\t\t\t\t" + proj.m_acqProgr + "\n";
                    output += "\t\t\t\t</program>\n";
                    output += "\t\t\t\t<technicalarea>\n";
                    output += "\t\t\t\t\t" + proj.m_techArea + "\n";
                    output += "\t\t\t\t</technicalarea>\n";

                    output += "\t\t\t\t<objective>\n";
                    output += "\t\t\t\t\t" + proj.m_objective + "\n";
                    output += "\t\t\t\t</objective>\n";
                    output += "\t\t\t\t<description>\n";
                    output += "\t\t\t\t\t" + proj.m_desc + "\n";
                    output += "\t\t\t\t</description>\n";

                    output += "\t\t\t\t<phaseI>\n";
                    output += "\t\t\t\t\t" + proj.m_phase1 + "\n";
                    output += "\t\t\t\t</phaseI>\n";
                    output += "\t\t\t\t<phaseII>\n";
                    output += "\t\t\t\t\t" + proj.m_phase2 + "\n";
                    output += "\t\t\t\t</phaseII>\n";

                    output += "\t\t\t\t<phaseIII>\n";
                    output += "\t\t\t\t\t" + proj.m_phase3 + "\n";
                    output += "\t\t\t\t</phaseIII>\n";
                    output += "\t\t\t\t<commercialization>\n";
                    output += "\t\t\t\t\t" + proj.m_commerc + "\n";
                    output += "\t\t\t\t</commercialization>\n";

                    output += "\t\t\t\t<references>\n";
                    output += "\t\t\t\t\t" + proj.m_refs + "\n";
                    output += "\t\t\t\t</references>\n";
                    output += "\t\t\t\t<keywords>\n";
                    output += "\t\t\t\t\t" + proj.m_keywords + "\n";
                    output += "\t\t\t\t</keywords>\n";
                    output += "\t\t\t</topic>\n";
                }
                output += "\t\t</RFP>\n";
                output += "\t</solicitation>";
            }
            output += "</SBIRDAT>";


            System.IO.File.WriteAllText(@"C:\!\sbirDB.xml", output);

            */
        }
    }
}
