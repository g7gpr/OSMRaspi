(window.webpackJsonp=window.webpackJsonp||[]).push([[29],{257:function(e,t,a){"use strict";a.r(t);var u,r=a(3),n=a(2),l=a(1),o=a(105),i=a(49),s=a(98),c=a(22),w=a(6),g=a(228),f=a(15),d=a(83),m=a(25),b=a(20),h=a(16),p=a(120),v=a(47),y=a(85),k=new m.a({color:"rgba(255, 153, 0, 0.8)"}),j=new b.a({color:"rgba(255, 204, 0, 0.2)",width:1}),x=new m.a({color:"#fff"}),O=new b.a({color:"rgba(0, 0, 0, 0.6)",width:3}),M=new m.a({color:"rgba(255, 255, 255, 0.01)"});function E(e){var t=e.get("name"),a=5+20*(parseFloat(t.substr(2))-5);return new h.c({geometry:e.getGeometry(),image:new p.a({radius1:a,radius2:3,points:5,angle:Math.PI,fill:k,stroke:j})})}var S,q=null;q=new c.a({source:new g.a({distance:40,source:new f.a({url:"data/kml/2012_Earthquakes_Mag5.kml",format:new o.a({extractStyles:!1})})}),style:function(e,t){t!=S&&(function(e){u=0;for(var t,a,r=q.getSource().getFeatures(),n=r.length-1;0<=n;--n){var o,i=(t=r[n]).get("features"),s=Object(l.j)(),c=void 0;for(c=0,o=i.length;c<o;++c)Object(l.q)(s,i[c].getGeometry().getExtent());u=Math.max(u,o),a=.25*(Object(l.E)(s)+Object(l.A)(s))/e,t.set("radius",a)}}(t),S=t);var a=e.get("features").length;return 1<a?new h.c({image:new v.a({radius:e.get("radius"),fill:new m.a({color:[255,153,0,Math.min(.8,.4+a/u)]})}),text:new y.a({text:a.toString(),fill:x,stroke:O})}):E(e.get("features")[0])}});var F=new w.a({source:new d.a({layer:"toner"})});new r.a({layers:[F,q],interactions:Object(i.a)().extend([new s.a({condition:function(e){return"pointermove"==e.type||"singleclick"==e.type},style:function(e){for(var t,a=[new h.c({image:new v.a({radius:e.get("radius"),fill:M})})],r=e.get("features"),n=r.length-1;0<=n;--n)t=r[n],a.push(E(t));return a}})]),target:"map",view:new n.a({center:[0,0],zoom:2})})}},[[257,0]]]);
//# sourceMappingURL=earthquake-clusters.js.map