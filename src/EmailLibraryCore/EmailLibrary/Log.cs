namespace EmailLibrary
{
    internal class Log
    {
        public static void Debug(string message)
        {
#if DEBUG
            Console.WriteLine($"[DEBUG] {message}");
#endif
        }
    }
}
