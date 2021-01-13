package com.exhibition.project;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.ibatis.session.SqlSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.exhibition.project.HDto.HDto;
import com.exhibition.project.HDto.IDto;
import com.exhibition.project.HDto.MDto;
import com.exhibition.project.HDao.HDao;



@Controller
public class HomeController {
	@Autowired
	private SqlSession sqlSession;
	private String Userid;
	HttpSession session;
	private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

	@RequestMapping("/home")
	public String home(Locale locale, Model model) {
		return "home";
	}
	
	@RequestMapping("/myInfo")
	public String myInfo(HttpServletRequest req, Model model) {
		HttpSession session=req.getSession();
		if(session.getAttribute("id") == null ||session.getAttribute("id").equals("")) {
            return "redirect:login";
         }
		HDao dao =sqlSession.getMapper(HDao.class);
		ArrayList<HDto> dto= dao.list();
		model.addAttribute("dto",dto);
		return "myInfo";
	}
	
	@RequestMapping(value="/login")
	public String doLogin() {
		return "login";
	}
	
	   @RequestMapping(value = "/loginCheck",method = RequestMethod.POST)
	   public String loginCheck(HttpServletRequest req, Model model) {
	      String id = req.getParameter("id");
	      String passwd = req.getParameter("passwd");
	      System.out.println(id);
	      System.out.println(passwd);
	      //session 이용 
	      HttpSession session = req.getSession();
	      HDao dao = sqlSession.getMapper(HDao.class);
	      int cnt = dao.memberCheck(id,passwd);
	      System.out.println(cnt);
	      if(cnt==1) {
	    	  System.out.println("debug3");
	         //==> 회원정보 존재 //
	         //==> uid담아줌
	         session.setAttribute("id", id);
	         Userid = id;
	         System.out.println("debug4");
	         model.addAttribute("cnt",cnt);
	      }else {
	         //==>회원정보 없음
	         return "redirect:login";
	      }
	     
	      return "redirect:welcomelogin";
	   }
	   
	   @RequestMapping(value="/checkId", method = RequestMethod.POST)
	   @ResponseBody
	   public String checkId(String userId) {
	      System.out.println("checkId()");
	      System.out.println(userId);
	      HDao dao =sqlSession.getMapper(HDao.class);
	      String result=dao.checkId(userId);
	      return result;
	   }
	   
	@RequestMapping("/welcomelogin")
	public String welcomelogin() {
		return "welcomelogin";
	}
	@RequestMapping("/logout")
	public String doLogout(HttpServletRequest req,Model model) {
		HttpSession session= req.getSession();
		session.invalidate();
		model.addAttribute("logout","logout");
		return "redirect:home";
	}
	
	@RequestMapping(value ="/signup")
	public String singon() {
		return "signup";
	}
	
	@RequestMapping(value="/getId")
	public String getId(HttpServletRequest req, Model model) {
		return "getId";
	}
	
	@RequestMapping(value="/dogetId",method = RequestMethod.POST)
	public String dogetId(HttpServletRequest req, Model model) {
		String name=req.getParameter("name");
		String email=req.getParameter("email");
		
	      System.out.println(name);
	      System.out.println(email);
	     
	    HttpSession session = req.getSession( );
	    HDao dao = sqlSession.getMapper(HDao.class);
	    HDto dto = dao.getId(name, email);
	    model.addAttribute("getid",dto);
	      return "dogetId";
	}
	@RequestMapping(value="/getPw")
	public String getPw(HttpServletRequest req, Model model) {
		return "getPw";
	}
	
	@RequestMapping(value="/dogetPw",method = RequestMethod.POST)
	public String dogetPw(HttpServletRequest req, Model model) {
		String id=req.getParameter("id");
		String email=req.getParameter("email");
	    HttpSession session = req.getSession( );
	    HDao dao = sqlSession.getMapper(HDao.class);
	    HDto dto= dao.getPw(id,email);
	    model.addAttribute("getpw",dto);
			return "dogetPw";
		}
	
	@RequestMapping(value="/welcomSignup",method = RequestMethod.POST)
	   public String welcomSignup(HttpServletRequest req, Model model) {
		  System.out.println("welcomSignup()");
	      String id = req.getParameter("id");
	      String email = req.getParameter("email");
	      String passwd = req.getParameter("passwd");
	      String gender = req.getParameter("gender");
	      String mobile = req.getParameter("mobile");
	      String address = req.getParameter("address");
	      String name = req.getParameter("name");
	      System.out.println(id);
	      System.out.println(email);
	      System.out.println(passwd);
	      System.out.println(gender);
	      System.out.println(mobile);
	      System.out.println(address);
	      System.out.println(name);
	      
	      HttpSession session = req.getSession( );
	      HDao dao = sqlSession.getMapper(HDao.class);
	      dao.signup(id,passwd,name,gender,email,mobile,address);
	      model.addAttribute("name", name);
	      return "welcomSignup";
	   }
	
	@RequestMapping("/modify_view")
	public String modify_view(HttpServletRequest req,Model model) {
		HttpSession session = req.getSession( );
		
		if(session.getAttribute("id") == null ||session.getAttribute("id").equals("")) {
            return "redirect:login";
         }
		HDao dao= sqlSession.getMapper(HDao.class);
		HDto dto = dao.modify_view(Userid);
		model.addAttribute("modify_view",dto);

		return "modify_view";
	}
	@RequestMapping("/modify")
	public String modify(HttpServletRequest req,Model model) {
		HttpSession session = req.getSession( );
		//==> view 에서 getParameter( ) 값이 modify ==> update(수정)
		//==> view 에서 getParameter( ) 값이 delete ==> delete(삭제)
		String hide = req.getParameter("hide");
		if(hide.equals("modify")) {
		String member_num = req.getParameter("member_num");
		String id=req.getParameter("id");
		String passwd = req.getParameter("passwd");
		String name=req.getParameter("name");
		String gender=req.getParameter("gender");
		String email=req.getParameter("email");
		String mobile=req.getParameter("mobile");
		String address=req.getParameter("address");
		HDao dao= sqlSession.getMapper(HDao.class);
		dao.modify(Integer.parseInt(member_num),id,passwd,name,gender,email,mobile,address);
		session.invalidate();
		return "redirect:modify_view";
		}else {
			System.out.println(hide);
			String member_num = req.getParameter("member_num");
			HDao dao = sqlSession.getMapper(HDao.class);
			dao.delete(member_num);
			session.invalidate();
			return "redirect:home";
		}
	}
	
	@RequestMapping ("/myList")
	public String myList (HttpServletRequest req,Model model) {
		System.out.println("myList()");
		HttpSession session=req.getSession();
		String userid=(String) session.getAttribute("id");
		System.out.println(userid);
		HDao dao =sqlSession.getMapper(HDao.class);
		ArrayList<IDto> dto_paint= dao.mylist_paint(userid);
		ArrayList<IDto> dto_photo= dao.mylist_paint(userid);
		ArrayList<IDto> dto_handi= dao.mylist_paint(userid);
		ArrayList<IDto> dto_music= dao.mylist_paint(userid);
		model.addAttribute("dto_paint",dto_paint);
		model.addAttribute("dto_photo",dto_photo);
		model.addAttribute("dto_handi",dto_handi);
		model.addAttribute("dto_music",dto_music);
		return "myList";
	}
	@RequestMapping ("/myItems")
	public String myItems (HttpServletRequest req, Model model) {
		System.out.println("myItems()");
		HttpSession session=req.getSession();
		String userid=(String) session.getAttribute("id");
		System.out.println(userid);
		HDao dao =sqlSession.getMapper(HDao.class);
		
		/*
		  select count(event) from itemevent where userid ='hello' and event = 'pick';
		  select count(event) from itemevent where userid ='hello' and event = 'buy';
		  select count(event) from itemevent where userid ='hello' and event = 'sell';
		 */
		int check1 = dao.eventCheck1(userid);
		int check2 = dao.eventCheck2(userid);
		int check3 = dao.eventCheck3(userid);
		
		ArrayList<MDto> dto_pick= dao.mylist_pick(userid);
		ArrayList<MDto> dto_buy= dao.mylist_buy(userid);
		ArrayList<MDto> dto_sell= dao.mylist_sell(userid);
		model.addAttribute("check1", check1);
		model.addAttribute("check2", check2);
		model.addAttribute("check3", check3);
	
		System.out.println("debug-myItems");
		System.out.println(dto_pick);
		System.out.println(dto_buy);
		System.out.println(dto_sell);
		

			model.addAttribute("dto_pick",dto_pick);
		model.addAttribute("dto_buy",dto_buy);
		model.addAttribute("dto_sell",dto_sell);
		return "myItems";
		}
		
	}




