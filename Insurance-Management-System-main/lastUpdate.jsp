<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Object ts = application.getAttribute("lastUpdate");
    if (ts == null) out.print("0"); else out.print(ts.toString());
%>
