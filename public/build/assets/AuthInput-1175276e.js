import{r as n,j as a,a as e}from"./app-33880e03.js";import{M as l,U as u}from"./user-46224ae2.js";import{c as o}from"./createLucideIcon-7e63c102.js";/**
 * @license lucide-react v0.553.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const f=[["path",{d:"M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49",key:"ct8e1f"}],["path",{d:"M14.084 14.158a3 3 0 0 1-4.242-4.242",key:"151rxh"}],["path",{d:"M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143",key:"13bj9a"}],["path",{d:"m2 2 20 20",key:"1ooewy"}]],b=o("eye-off",f);/**
 * @license lucide-react v0.553.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const x=[["path",{d:"M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0",key:"1nclc0"}],["circle",{cx:"12",cy:"12",r:"3",key:"1v7zrd"}]],k=o("eye",x);/**
 * @license lucide-react v0.553.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const w=[["rect",{width:"18",height:"11",x:"3",y:"11",rx:"2",ry:"2",key:"1w4ew1"}],["path",{d:"M7 11V7a5 5 0 0 1 10 0v4",key:"fwvmzm"}]],g=o("lock",w),N={user:u,mail:l,lock:g},I=n.forwardRef(function({label:i,icon:d,error:t,type:r,...p},h){const[s,m]=n.useState(!1),y=N[d]||l,c=r==="password";return a("div",{className:"mb-4",children:[e("label",{className:"block text-sm font-semibold text-gray-700 mb-1",children:i}),a("div",{className:"relative",children:[e("div",{className:"absolute left-3 top-1/2 -translate-y-1/2 text-gray-400",children:e(y,{className:"w-5 h-5"})}),e("input",{ref:h,type:c&&s?"text":r,className:`w-full pl-10 pr-4 py-3 rounded-xl border transition-all duration-200 bg-white placeholder-gray-400 text-gray-800 ${t?"border-red-300 focus:ring-red-500 focus:border-red-500":"border-gray-200 hover:border-pink-300 focus:ring-2 focus:ring-pink-500 focus:border-pink-500"}`,...p}),c&&e("button",{type:"button",onClick:()=>m(!s),className:"absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-pink-500 transition-colors",children:s?e(b,{className:"w-5 h-5"}):e(k,{className:"w-5 h-5"})})]}),t&&a("p",{className:"mt-1.5 text-sm text-red-500 flex items-center gap-1",children:[e("span",{className:"inline-block w-1 h-1 bg-red-500 rounded-full"}),t]})]})});export{I as A};
