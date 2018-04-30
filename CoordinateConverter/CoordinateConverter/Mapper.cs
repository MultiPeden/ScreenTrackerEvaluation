namespace CoordinateConverter
{

    using Microsoft.Kinect;
    using Newtonsoft.Json;

    class Mapper
    {

        CoordinateMapper mapper;
        private KinectSensor kinectSensor = null;



        public Mapper()
        {
            // get the kinectSensor object
            this.kinectSensor = KinectSensor.GetDefault();
            // open the Kinect sensor
            this.kinectSensor.Open();

            // get conversiontable between depthframe to cameraspace
            this.mapper = kinectSensor.CoordinateMapper;



        }

        private void WaitForSensor()
        {
            while (!kinectSensor.IsAvailable)
            {
                System.Threading.Thread.Sleep(2000);
            }
        }



        public void testeren(string filename, string path)
        {



            WaitForSensor();

            /*
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };*/





            using (System.IO.StreamReader fileIn = new System.IO.StreamReader(path + filename, true))
            using (System.IO.StreamWriter fileOut = new System.IO.StreamWriter(path + "CameraSpace" + filename, false))
            {


                while (!fileIn.EndOfStream)
                {
                    string str = fileIn.ReadLine();



                    Items items = ConvertCoordinates(str);




                    string output = JsonConvert.SerializeObject(items);
                    //  Console.WriteLine(output);
                    fileOut.WriteLine(output);

                }
                fileOut.Flush();
            }
        }


        public Items ConvertCoordinates(string str)
        {


            Items items = JsonConvert.DeserializeObject<Items>(str);

            CameraSpacePoint[] cameraSpacePoints = new CameraSpacePoint[items.items.Length];
            DepthSpacePoint[] dps = new DepthSpacePoint[items.items.Length];
            ushort[] zCoords = new ushort[items.items.Length];

            DepthSpacePoint dp;

            IRpoint[] points = items.items;
            IRpoint point;

            for (int i = 0; i < points.Length; i++)
            {

                point = points[i];
                dp = new DepthSpacePoint
                {
                    X = point.x,
                    Y = point.y
                };
                zCoords[i] = (ushort)(point.z);
                dps[i] = dp;

            }



            CameraSpacePoint cameraSpacePoint;



            mapper.MapDepthPointsToCameraSpace(dps, zCoords, cameraSpacePoints);

            //  System.Threading.Thread.Sleep(5000);

            for (int i = 0; i < cameraSpacePoints.Length; i++)
            {

                point = points[i];
                cameraSpacePoint = cameraSpacePoints[i];
                point.x = cameraSpacePoint.X;
                point.y = cameraSpacePoint.Y;
                point.z = cameraSpacePoint.Z;


            }

            return items;

        }

    }

}

