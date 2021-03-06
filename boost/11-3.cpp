#include <boost/spirit/include/qi.hpp>
#include <string>
#include <iostream>

using namespace boost::spirit;

int main()
{
  std::string s;
  std::getline(std::cin, s);
  auto it = s.begin();
  bool match = qi::phrase_parse(it, s.end(), ascii::digit, ascii::space,
    qi::skip_flag::dont_postskip);
  std::cout << std::boolalpha << match << ":" << *it << '\n';
  if (it != s.end())
    std::cout << std::string{it, s.end()} << '\n';
}

