// clang -c ch8_9_2.cpp -emit-llvm -o ch8_9_2.bc
// /Users/Jonathan/llvm/test/cmake_debug_build/bin/Debug/llc -march=cpu0 -relocation-model=pic -filetype=asm ch8_9_2.bc -o ch8_9_2.cpu0.s
class Date
{
private:
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;
public:
  Date(int year, int month, int day, int hour, int minute, int second);
  Date getDate();
};

Date::Date(int year, int month, int day, int hour, int minute, int second)
{
  this->year = year;
  this->month = month;
  this->day = day;
  this->hour = hour;
  this->minute = minute;
  this->second = second;
}

Date Date::getDate()
{ 
  return *this;
}

int main()
{
  Date date1 = Date(2013, 1, 26, 12, 21, 10);
  Date date2 = date1.getDate();

  return 0;
}
