const test=require('node:test');const assert=require('node:assert/strict');
const {validarSolicitud,construirPrompt,extraerRespuesta}=require('../prompt');
test('acepta historial válido y nivel MCER',()=>{assert.equal(validarSolicitud({nivel:'A1',mensajes:[{role:'user',content:'Hello'}]}),null);});
test('rechaza texto mayor a 500 caracteres',()=>{assert.match(validarSolicitud({nivel:'A1',mensajes:[{role:'user',content:'x'.repeat(501)}]}),/mensaje inválido/);});
test('rechaza roles que no alternan',()=>{assert.match(validarSolicitud({nivel:'B1',mensajes:[{role:'user',content:'Hi'},{role:'user',content:'Again'}]}),/alternarse/);});
test('prompt limita correcciones y exige pregunta',()=>{const p=construirPrompt('A2');assert.match(p,/como máximo 2/);assert.match(p,/pregunta/);});
test('valida y recorta estructura de salida',()=>{const r=extraerRespuesta('```json\n{"respuesta":"Good!","correcciones":[],"siguientePregunta":"And you?"}\n```');assert.equal(r.respuesta,'Good!');assert.equal(r.siguientePregunta,'And you?');});
test('rechaza JSON incompleto',()=>{assert.throws(()=>extraerRespuesta('nada'));});
