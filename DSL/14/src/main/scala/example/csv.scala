import scala.io.Source
import java.io.PrintWriter

object Main extends App {
 
    var source =Source.fromFile("1.csv","utf-8").getLines.foreach{
      a=>;
      var b=a.split(",");
      var pa = b(25)
      println(pa)

      regexMatchSample(pa.toString)

      def regexMatchSample(s: String): Unit = {
      val regex = """(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3}).*""".r
      // val pattern = """/(?<!\d)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?!\d)/""".r
      val pattern2 = """(.+)(Web)(.+)""".r
      s match {
        case regex(ip1,ip2,ip3,ip4) => println(ip1, ip2, ip3, ip4)
	case pattern2(str1,str2,str3) => println("match:" + str1 + "," + str2 + "," + str3)
	case _ => println("not match")
	}
      }


    }
}

