<Query Kind="Statements" />

List<string> lnList = new List<string>();


using (StreamReader file = new StreamReader("C:\\Users\\dape\\Desktop\\OWD\\OWD\\result.txt"))
{
	int counter = 0;
	string ln;

	while ((ln = file.ReadLine()) != null)
	{
		lnList.Add(ln);
		counter++;
	}
	file.Close();
}

for (int i = 1; i < lnList.Count();)
{
	if (lnList[i].Length > 1 && lnList[i][0] == '#')
	{
		i++;
		Console.WriteLine($"{lnList[i]};{lnList[i + 1]};{lnList[i + 2]};{lnList[i+3]};{lnList[i+4]}");
		i=i+6;
	}
}