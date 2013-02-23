// clang -c ch8_9_1.cpp -emit-llvm -o ch8_9_1.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_9_1.bc -o ch8_9_1.cpu0.s

struct Date
{
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;
};
Date gDate = {2012, 10, 12, 1, 2, 3};

struct Time
{
  int hour;
  int minute;
  int second;
};
Time gTime = {2, 20, 30};

Date getDate()
{ 
  return gDate;
}

Date copyDate(Date date)
{ 
  return date;
}

Date copyDate(Date* date)
{ 
  return *date;
}

Time copyTime(Time time)
{ 
  return time;
}

Time copyTime(Time* time)
{ 
  return *time;
}

int main()
{
  Time time1 = {1, 10, 12};
  Date date1 = getDate();
  Date date2 = copyDate(date1);
  Date date3 = copyDate(&date1);
  Time time2 = copyTime(time1);
  Time time3 = copyTime(&time1);

  return 0;
}
