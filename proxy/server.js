'use strict';
const http=require('node:http');
const {validarSolicitud,construirPrompt,extraerRespuesta}=require('./prompt');
function crearServidor({apiKey=process.env.ANTHROPIC_API_KEY,token=process.env.APP_TOKEN,fetchFn=fetch,limite=30}={}){
 const uso=new Map();
 return http.createServer(async(req,res)=>{
  res.setHeader('Content-Type','application/json; charset=utf-8');
  const enviar=(s,o)=>{res.writeHead(s);res.end(JSON.stringify(o));};
  if(req.method==='GET'&&req.url==='/health')return enviar(200,{ok:true,servicio:'Habla Fluido'});
  if(req.method!=='POST'||req.url!=='/chat')return enviar(404,{error:'No encontrado'});
  if(token&&req.headers['x-app-token']!==token)return enviar(401,{error:'No autorizado'});
  const ip=req.socket.remoteAddress||'local',ahora=Date.now(),lista=(uso.get(ip)||[]).filter(t=>ahora-t<60000);
  if(lista.length>=limite)return enviar(429,{error:'Límite de uso alcanzado'});
  lista.push(ahora);uso.set(ip,lista);
  let raw='';for await(const chunk of req){raw+=chunk;if(raw.length>20000)return enviar(413,{error:'Solicitud demasiado grande'});}
  let body;try{body=JSON.parse(raw);}catch{return enviar(400,{error:'JSON inválido'});}
  const error=validarSolicitud(body);if(error)return enviar(400,{error});
  if(!apiKey)return enviar(503,{error:'Tutor IA no configurado. Usa el modo de práctica local.'});
  try{
   const upstream=await fetchFn('https://api.anthropic.com/v1/messages',{method:'POST',headers:{'content-type':'application/json','x-api-key':apiKey,'anthropic-version':'2023-06-01'},
    body:JSON.stringify({model:process.env.MODEL||'claude-3-5-haiku-latest',max_tokens:700,system:construirPrompt(body.nivel),messages:body.mensajes})});
   if(!upstream.ok)return enviar(502,{error:'Tutor no disponible'});
   const data=await upstream.json(),contenido=(data.content||[]).find(x=>x.type==='text')?.text||'';
   return enviar(200,extraerRespuesta(contenido));
  }catch{return enviar(502,{error:'Tutor no disponible'});}
 });
}
if(require.main===module){const s=crearServidor();s.listen(process.env.PORT||3000,'0.0.0.0',()=>console.log('Proxy Habla Fluido listo'));}
module.exports={crearServidor};
