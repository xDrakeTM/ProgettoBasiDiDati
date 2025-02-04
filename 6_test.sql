-- OPERAZIONI

/*------------------------------------------------------
 Operazione 1 (paragrafo 4.2.1) - CostoLavoriProgetto
*/------------------------------------------------------
select CostoLavoriProgetto(1);

/*------------------------------------------------------
 Operazione 2 (paragrafo 4.2.2) - ListaProgettiAttuali
*/------------------------------------------------------
update avanzamento
set DataFineEffettiva = current_date() + interval 1 month
where ID = 1;

call ListaProgettiAttuali();

/*------------------------------------------------------
 Operazione 3 (paragrafo 4.2.3) - InserimentoTurnoOperaio
*/------------------------------------------------------
insert into impiegosupervisore values ('2020-01-04 09:00:00', '2020-01-04 18:00:00', 1, 'XXRXXX92M02G865F') -- deve essere presente anche un supervisore durante il turno di un operaio

call InserimentoTurnoOperaio(1, 'XXXXXH92M02G865F', '2020-01-04 09:00:00', '2020-01-04 18:00:00');

/*------------------------------------------------------
 Operazione 4 (paragrafo 4.2.4) - CalcoloStipendi
*/------------------------------------------------------
call CalcoloStipendi(2020, 4);

/*------------------------------------------------------
 Operazione 5 (paragrafo 4.2.5) - ListaTurniSettimanali
*/------------------------------------------------------
 ListaTurniSettimanali('XXXXXH92M02G865F');

/*------------------------------------------------------
 Operazione 6 (paragrafo 4.2.6) - InserimentoMisura
*/------------------------------------------------------
call InserimentoMisura (now(), 1.0, 1.3, 0, 1);

/*------------------------------------------------------
 Operazione 7 (paragrafo 4.2.7) - ListaMisureEdificio
*/------------------------------------------------------
call ListaMisureEdificio(1);

/*------------------------------------------------------
 Operazione 8 (paragrafo 4.2.8) - DatiEdificio
*/------------------------------------------------------
call DatiEdificio(1);

-- STATO EDIFICIO
set @ris = 0;
call stato_edificio(2,'2023-03-03 04:00:00', @ris);
select @ris;

-- CALAMITÀ
call stima_calamita(1, current_timestamp(), 'Fuoco', 79.80, 13.82, @Risultato);

select @Risultato;

-- ANALYTICS

-- analytic 1: consigli di intervento
call consigli_di_intervento(1, now());

select *
from consigli_di_intervento;

-- analytic 2: stima dei danni
call stima_danni(2, 5, 79.80, 13.82);
