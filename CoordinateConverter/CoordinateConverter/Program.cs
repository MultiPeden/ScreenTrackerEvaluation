using System.IO;

namespace CoordinateConverter
{


    class Program
    {







        static void Main(string[] args)
        {




            if (args.Length == 1)
            {
                string filename = args[0];
                if (File.Exists(filename))
                {
                    Mapper mapper = new Mapper();
                    mapper.testeren(filename, "");
                    System.Console.WriteLine("Mapped data and saved to: " + "CameraSpace" + filename);

                }
                else
                {
                    System.Console.WriteLine("File: " + filename + " Does not exist");
                }


            }
            else
            {
                Mapper mapper = new Mapper();
                mapper.testeren("trackingNullOut.txt", "C:\\test\\");





            }


        }
    }
}
