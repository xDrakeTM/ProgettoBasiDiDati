use progetto_carinci_difabrizio;
/*------------------------------------------------------
    1. Costo lavori di un progetto edilizio
    2. Lista progetti in stato di esecuzione
    3. Inserimento turni operaio
    4. Calcolo stipendi
    5. Lista turni settimanale
    6. Inserimento misura
    7. Lista misure di un edificio
    8. Dati di un edificio
*/-- ----------------------------------------------------

/*------------------------------------------------------
 Operazione 1 (paragrafo 4.2.1) - CostoLavoriProgetto
*/------------------------------------------------------
drop function if exists CostoLavoriProgetto;
delimiter $$
create function CostoLavoriProgetto(_IDProgetto int)
returns float
reads sql data
not deterministic
begin
	declare _costo float;
    
    select PE.CostoLavori into _costo
    from ProgettoEdilizio PE
    where PE.ID = _IDProgetto;
    
    return _costo;
    
end $$
delimiter ;
;

/*------------------------------------------------------
 Operazione 2 (paragrafo 4.2.2) - ListaProgettiAttuali
*/------------------------------------------------------
drop procedure if exists ListaProgettiAttuali;
delimiter $$
create procedure ListaProgettiAttuali()
begin
    select PE.ID as IDProgetto, PE.Tipo as TipoProgetto, PE.DataInizio, 
			PE.StimaDataFine, A.ID as IDStadio, PE.Edificio_ID as IDEdificio, E.Tipologia as TipoEdificio
	from ProgettoEdilizio PE
		inner join
        Edificio E on PE.Edificio_ID = E.ID
        inner join
        Avanzamento A on PE.ID = A.ProgettoEdilizio_ID
	where ( A.DataFineEffettiva is null or A.DataFineEffettiva > current_date() )
		and A.DataInizio <= current_date();   
end $$
delimiter ;
;

/*------------------------------------------------------
 Operazione 3 (paragrafo 4.2.3) - InserimentoTurnoOperaio
*/------------------------------------------------------
drop procedure if exists InserimentoTurnoOperaio;
delimiter $$
create procedure InserimentoTurnoOperaio(in _IDLavoro int,
										 in _CF char(16),
                                         in _InizioImpiego datetime,
                                         in _FineImpiego datetime)
begin
	declare _supervisore varchar(16);
    select L.Supervisore_ID into _supervisore
    from Lavoro L
    where L.ID = _IDLavoro;

-- check numero massimo di operai contestuali nel lavoro
if (select count(distinct I.Operaio_CodiceFiscale) 
	from ImpiegoOperaio I
    where I.Operaio_CodiceFiscale <> _CF
		and I.Lavoro_ID = _IDLavoro
        and (	(I.InizioImpiego <= _InizioImpiego and I.FineImpiego > _InizioImpiego)  -- nuovo impiego inizia dopo la data di inizio impiego dell'operaio già presente ma prima della data di fine
			or
				(I.InizioImpiego > _InizioImpiego and I.InizioImpiego < _FineImpiego) )
	) >=
    (select LA.MaxOperai
     from Lavoro LA
     where LA.ID = _IDLavoro) then
		signal sqlstate "45000"
        set message_text = "Raggiunto numero massimo operai contestuali per questo lavoro";
end if;

-- check presenza del supervisore durante il turno di lavoro
if (select count(*) 
	from ImpiegoSupervisore I
    where I.Lavoro_ID = _IDLavoro 
		and I.Supervisore_CodiceFiscale = _supervisore
        and I.InizioImpiego <= _InizioImpiego 
        and I.FineImpiego >= _FineImpiego) = 0 then
			signal sqlstate "45000"
            set message_text = "Durante il turno non è presente il supervisore";
end if;

-- check massimo numero operai coordinabili dal supervisore
if (select count(distinct I.Operaio_CodiceFiscale) 
	from ImpiegoOperaio I
    where I.Operaio_CodiceFiscale <> _CF
		and I.Lavoro_ID = _IDLavoro
	) >=
    (select S.MaxOperai
     from Supervisore S
     where S.CodiceFiscale = _supervisore) then
		signal sqlstate "45000"
        set message_text = "Raggiunto numero massimo di operai coordinabili dal supervisore";
end if;

-- check sovrapposizioni di altri turni dell'operaio
if( select count(*) 
	from ImpiegoOperaio I
    where I.Operaio_CodiceFiscale = _CF
		and  (	(I.InizioImpiego <= _InizioImpiego and I.FineImpiego > _InizioImpiego) 
			or
				(I.InizioImpiego > _InizioImpiego and I.InizioImpiego < _FineImpiego) ) ) > 0 then
					signal sqlstate "45000"
                    set message_text = "Sovrapposizione nuovo turno con turni già presenti dell'operaio";
end if;
    

-- inserimento dopo aver passato tutti i check
insert into ImpiegoOperaio
values (_InizioImpiego, _FineImpiego, _IDLavoro, _CF);

end $$
delimiter ;
;

/*------------------------------------------------------
 Operazione 4 (paragrafo 4.2.4) - CalcoloStipendi
*/------------------------------------------------------
drop procedure if exists CalcoloStipendi;
delimiter $$
create procedure CalcoloStipendi(in _anno int, in _mese int)
begin
    select O.CodiceFiscale, sum(timestampdiff(hour, I1.InizioImpiego, I1.FineImpiego) * O.PagaOraria) as Stipendio
    from Operaio O 
        inner join
        ImpiegoOperaio I1 on O.CodiceFiscale = I1.Operaio_CodiceFiscale
    where year(I1.InizioImpiego) = _anno
        and month(I1.InizioImpiego) = _mese
    group by O.CodiceFiscale
    union all
    select S.CodiceFiscale, sum(timestampdiff(hour, I2.InizioImpiego, I2.FineImpiego) * S.PagaOraria) as Stipendio
    from Supervisore S
        inner join
        ImpiegoSupervisore I2 on S.CodiceFiscale = I2.Supervisore_CodiceFiscale
    where year(I2.InizioImpiego) = _anno
        and month(I2.InizioImpiego) = _mese
    group by S.CodiceFiscale;
end $$
delimiter ;
; 
 
/*------------------------------------------------------
 Operazione 5 (paragrafo 4.2.5) - ListaTurniSettimanali
*/------------------------------------------------------
drop procedure if exists ListaTurniSettimanali;
delimiter $$
create procedure ListaTurniSettimanali(in _CF char(16))
begin
    select I.InizioImpiego, I.FineImpiego, L.Tipo as TipoLavoro, L.Supervisore_ID
    from ImpiegoOperaio I
        inner join
        Lavoro L on I.Lavoro_ID = L.ID
    where I.Operaio_CodiceFiscale = _CF
        and I.InizioImpiego >= current_timestamp
        and I.FineImpiego <= current_timestamp + interval 1 week
    order by 
    I.InizioImpiego; 
    end $$
delimiter ;
; 
 
/*------------------------------------------------------
 Operazione 6 (paragrafo 4.2.6) - InserimentoMisura
*/------------------------------------------------------
drop procedure if exists InserimentoMisura;
delimiter $$
create procedure InserimentoMisura (in _Timestamp datetime(4),
									in _valoreX float,
                                    in _valoreY float,
                                    in _valoreZ float,
                                    in _IDSensore int)
begin
	declare _soglia float;
    
    if _Timestamp is null then
		set _Timestamp = current_timestamp(4);
	end if;
    
    insert into Misura(Timestamp, xOppureUnico, y, z, Sensore_ID)
    values (_Timestamp, _valoreX, _valoreY, _valoreZ, _IDSensore);
    
	select s.Soglia into _soglia
    from sensore s
    where s.ID = _IDSensore;
    
    if(_valoreX >= _soglia or _valoreY >= _soglia or _valoreZ >= _soglia) then
		insert into alert(Misura_Timestamp, Misura_Sensore_ID)
        values (_Timestamp, _IDSensore);
	end if;

end $$
delimiter ;
;

/*------------------------------------------------------
 Operazione 7 (paragrafo 4.2.7) - ListaMisureEdificio
*/------------------------------------------------------
drop procedure if exists ListaMisureEdificio;
delimiter $$
create procedure ListaMisureEdificio(in _IDEdificio int)
begin
    select S.ID as IDSensore, S.Tipologia, M.Timestamp, M.XOppureUnico as ValoreX, M.y as ValoreY, M.z as ValoreZ
    from Vano V 
        inner join
        Sensore S on V.ID = S.Vano_ID
        inner join
        Misura M on S.ID = M.Sensore_ID 
    where V.Edificio_ID = _IDEdificio  
        and M.Timestamp <= current_timestamp
        and M.Timestamp > current_timestamp - interval 1 week;
end $$
delimiter ;
;
 
/*------------------------------------------------------
 Operazione 8 (paragrafo 4.2.8) - DatiEdificio
*/------------------------------------------------------
drop procedure if exists DatiEdificio;
delimiter $$
create procedure DatiEdificio(in _IDEdificio int)
begin
    select E.Tipologia, P.Numero as NumeroPiano, V.ID as IDVano, V.AltezzaMax as AltezzaMassimaVano,
        V.Lunghezza * V.Larghezza as SuperficieVano
    from Edificio E 
        inner join
        Piano P on E.ID = P.Edificio_ID
        inner join
        Vano V on P.Edificio_ID = V.Edificio_ID
    where E.ID = _IDEdificio
    order by P.Numero;
end $$
delimiter ;
;
 