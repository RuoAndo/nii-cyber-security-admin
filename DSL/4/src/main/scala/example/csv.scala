import scala.io.Source
import java.io.PrintWriter

case class PA (alarm_id: Int, timestamp: String)

object Main extends App {

def caseClassMatchSample(pa: PA)
{
    pa match {
		case PA(77943409,_) => {
	     	  println("MATCH:77943409")
	     	       }
		case _ => {
	     	  // println("NO MATCH")
	     	  }
	     }
}

def address_format(line : String, out : PrintWriter) = {
    val list = line split ','

    // val concat_str = list(0) + list(1)
    caseClassMatchSample(PA(list(0).toInt, list(1).replaceAll(" ","_").toString))
    out.write("%s,%s\n" format (list(0), list(1)))
}

val source = Source.fromFile("1.csv", "utf8")
val out = new PrintWriter("out.txt", "utf8")

val lines = source.getLines
lines.foreach(line => address_format(line, out))
source.close
out.close
}

