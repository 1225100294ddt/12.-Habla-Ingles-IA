'use strict';
const NIVELES=['A1','A2','B1','B2','C1'];
function validarSolicitud(body){
 if(!body || !NIVELES.includes(body.nivel))return 'nivel inválido';
 const m=body.mensajes;
 if(!Array.isArray(m)||m.length<1||m.length>20)return 'historial inválido';
 if(m[0].role!=='user'||m[m.length-1].role!=='user')return 'el historial debe empezar y terminar con el estudiante';
 for(let i=0;i<m.length;i++){
  if(!m[i]||!['user','assistant'].includes(m[i].role)||typeof m[i].content!=='string'||!m[i].content.trim()||m[i].content.length>500)return 'mensaje inválido';
  if(i>0&&m[i].role===m[i-1].role)return 'los roles deben alternarse';
 }
 return null;
}
function construirPrompt(nivel){
 return `Eres un tutor amable de inglés para nivel ${nivel}. Responde en inglés sencillo apropiado al nivel. Primero responde al contenido del estudiante, corrige como máximo 2 errores importantes y explica cada corrección brevemente. Termina SIEMPRE con una pregunta para continuar. Devuelve JSON con respuesta, correcciones [{original,corregido,explicacion}] y siguientePregunta.`;
}
function extraerRespuesta(raw){
 const a=raw.indexOf('{'),b=raw.lastIndexOf('}');
 if(a<0||b<=a)throw Error('JSON inválido');
 const o=JSON.parse(raw.slice(a,b+1));
 if(typeof o.respuesta!=='string'||!o.respuesta.trim()||o.respuesta.length>1000)throw Error('respuesta inválida');
 const correcciones=Array.isArray(o.correcciones)?o.correcciones.slice(0,5).filter(c=>c&&['original','corregido','explicacion'].every(k=>typeof c[k]==='string'&&c[k].trim())):[];
 return {respuesta:o.respuesta.trim(),correcciones,siguientePregunta:typeof o.siguientePregunta==='string'?o.siguientePregunta.slice(0,300):''};
}
module.exports={validarSolicitud,construirPrompt,extraerRespuesta};
