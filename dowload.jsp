<%@ page language="java" pageEncoding="utf-8"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="seed.utils.*" %>
<%@ include file="/WEB-INF/views/_extra/dao/commonFileDao.jsp"%>
<%@ include file="/WEB-INF/views/_extra/dao/infoManagementDao.jsp"%>

<%

	SeedProperties seedProperties = new SeedProperties();
	String rootPath = seedProperties.getConfigValue("root.path");
	
	String memberIdx = SeedUtils.setReplaceNull(session.getAttribute("memberIdx"));
	String dataIdx = SeedUtils.setReplaceNullXss(request.getParameter("dataIdx"));
	String pathKey1 = SeedUtils.setReplaceNullXss(request.getParameter("pathKey1"));
	String pathKey2 = SeedUtils.setReplaceNullXss(request.getParameter("pathKey2"));
	String funcType = SeedUtils.setReplaceNullXss(request.getParameter("funcType"));
	String inDown = SeedUtils.setReplaceNullXss(request.getParameter("inDown"));
	String postIdx = SeedUtils.setReplaceNullXss(request.getParameter("postIdx"));
	String infoIdx = SeedUtils.setReplaceNullXss(request.getParameter("infoIdx"));
	
	pathKey1 = SeedUtils.setFilePathReplaceAll(pathKey1);
	pathKey2 = SeedUtils.setFilePathReplaceAll(pathKey2);
	funcType = SeedUtils.setFilePathReplaceAll(funcType);
	
	SeedSqlCon seedSqlCon 			= null;
	InputStream in = null;
    OutputStream os = null;
	boolean success					= true;
	
	try{
		
		if(!"".equals(dataIdx) && !"".equals(funcType)){
			
			seedSqlCon = new SeedSqlCon("");
			
			Map<String,Object> extraFileInfo = null; 
			
			String fileReName	= "";
			String fileName = "";
			String filePath = rootPath + "/" + pathKey1 + "/upload/"+funcType;
			Integer fileSize = 0;
			
			//funcType이 download일 경우 download폴더 하위의 일반 파일 및 특정 파일을 다운로드 하는 로직으로 동작 하게 됩니다.
			if("download".equals(funcType)){
				fileReName = dataIdx;
				fileName = dataIdx;
				filePath = rootPath + "/" + pathKey1 + "/upload/"+funcType;
			}else{
				extraFileInfo 	= getExtraFileInfo(seedSqlCon, dataIdx);
				fileReName = SeedUtils.setReplaceNull(extraFileInfo.get("EXTRA_FILE_RENAME"));
				fileName = SeedUtils.setReplaceNull(extraFileInfo.get("EXTRA_FILE_NAME"));
				fileSize = Integer.parseInt(SeedUtils.setReplaceNull(extraFileInfo.get("EXTRA_FILE_SIZE"), "0"));
				filePath = rootPath + "/" + pathKey1 + "/upload/"+funcType+"/"+pathKey2;
				
				if(fileReName.indexOf("-") > -1 && fileReName.indexOf("/upload/") > -1){
					filePath = rootPath.replaceAll("/WEB-INF/views/site", "");
				}
			}
			
			if(!"".equals(fileReName)){
			    File file = null;
			    
			    out.clear();
		    	pageContext.pushBody();
		    	
		    	try{
		            file = new File(filePath, fileReName);
		            in = new FileInputStream(file);
		        }catch(FileNotFoundException fe){
		        	success = false;
		        }
		    	
		    	String client = request.getHeader("User-Agent");
		        response.reset() ;
		        response.setContentType("application/octet-stream");
		        response.setHeader("Content-Description", "JSP Generated Data");
		        
		        if(success){
		        	//취약점 개행문자 제거 2016-09-19
		        	fileName = fileName.replaceAll("\r", "").replaceAll("\n", "");
		        	
		            if(client.indexOf("MSIE") != -1 || client.indexOf("Trident") != -1){
		                response.setHeader("Content-Disposition", "attachment; filename=\""+URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20")+"\"");
		            } else if (request.getHeader("User-Agent").indexOf("Chrome") > -1) {//크롬 브라우저 
		                StringBuffer sb = new StringBuffer();
		                for (int i = 0; i < fileName.length(); i++) {
		                    char c = fileName.charAt(i);
		                    if (c > '~') {
		                        sb.append(URLEncoder.encode("" + c, "UTF-8"));
		                    } else {
		                        sb.append(c);
		                    }
		                }
		                response.setHeader("Content-Disposition", "attachment; filename=\""+sb.toString().replaceAll("\\+", "%20")+"\"");
		            }else{
		                response.setHeader("Content-Disposition", "attachment; filename=\""+new String(fileName.getBytes("UTF-8"), "8859_1").replaceAll("\\+", "%20")+"\"");
		                response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
		            }  
		            
		            response.setHeader ("Content-Length", ""+file.length() );
		            os = response.getOutputStream();
		            
		            int buffer = 1024;
		            
		            if(fileSize > 10485760){//10메가보다 클 경우
		            	SeedUtils.setErrorLog("fileSize > 10485760 : "+true);
		            	buffer = 8192;
		            }
		            
		            byte b[] = new byte[buffer];
		            int leng = 0;
		            while( (leng = in.read(b)) > 0 ){
		                os.write(b,0,leng);
		            }
		        }
		        
		        if(inDown.equals("front") && success == true){
					setExtraFileCtn(seedSqlCon, dataIdx);
				}

				if(success == true && funcType.equals("infoManagement") && !postIdx.equals("")){
					
					String linkUrl = request.getHeader("referer");
					
					if(linkUrl.indexOf("user") > -1){
						linkUrl = linkUrl.substring(linkUrl.indexOf("user")-1);
					}
					if(linkUrl.indexOf("&CSRFToken") > -1){
						linkUrl = linkUrl.substring(0,linkUrl.indexOf("&CSRFToken"));
					}
					
					updateDownCnt(seedSqlCon, postIdx);
					addDownInfo(seedSqlCon, postIdx, memberIdx, infoIdx, linkUrl);
				}
		        
			}
		}
	}catch(NumberFormatException e){
		SeedUtils.setErrorLog("NumberFormatException "+e.getMessage());
	}catch(Exception e){
		SeedUtils.setErrorLog("download.jsp 파일에서 에러 발생 Exception");
	}finally{
		if(seedSqlCon != null){
			seedSqlCon.setSeedSqlDispose();
		}
		if(in!=null)try{in.close();}catch(Exception e){}
    	if(os!=null)try{os.close();}catch(Exception e){}
	}
	
	if(!success){
		response.setContentType("text/html;charset=UTF-8");
	    out.println("<script language='javascript'>alert('파일을 찾을 수 없습니다');history.back();</script>");
	}
	
%>