// package jp.sf.amateras.scala.util

object ParserSample extends App {

  val parser = new IniParser

  val result = parser.parseAll(parser.property, """
  Virus/Win32.WGeneric.vhqug(219379899)
""")

  val p= result.get
  println(p)

  /*
  val map = sections.sections.map { section =>
    (section.name.string -> section.properties.map { property =>
      (property.key.string -> property.value.string)
    }.toMap)
  }.toMap
  */

  //println(map)
}

import scala.util.parsing.combinator.RegexParsers

class IniParser extends RegexParsers {

  def string :Parser[ASTString] = """[^\[\]\(\)=\s]*""".r^^{
    case value => ASTString(value)
  }

  def property :Parser[ASTProperty] = string~"("~string~")" ^^{
    case key~_~value~_ => ASTProperty(key, value)
  }
}

trait AST

case class ASTString(string: String) extends AST
case class ASTProperty(key: ASTString, value: ASTString) extends AST

