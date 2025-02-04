-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- dichiarazione di variabili costanti e persistenti
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
delimiter $$

drop function if exists costante_accelerometro $$
create function costante_accelerometro()
returns float deterministic
begin return 10; end $$

drop function if exists costante_giroscopio $$
create function costante_giroscopio()
returns float deterministic
begin return 5; end $$

drop function if exists costante_estensimetro $$
create function costante_estensimetro()
returns float deterministic
begin return 1; end $$

drop function if exists costante_termometro $$
create function costante_termometro()
returns float deterministic
begin return 0.5; end $$

drop function if exists costante_igrometro $$
create function costante_igrometro()
returns float deterministic
begin return 0.25; end $$

drop function if exists peso_struttura $$
create function peso_struttura()
returns float deterministic
begin return 1; end $$

drop function if exists peso_muri $$
create function peso_muri()
returns float deterministic
begin return 1; end $$

drop function if exists peso_ambiente $$
create function peso_ambiente()
returns float deterministic
begin return 0.5; end $$
delimiter ;
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop function if exists media_soprasoglia;
delimiter $$
create function media_soprasoglia(_edificio int, _tiposensore varchar(50), _datainizio datetime, _datafine datetime)
returns float
deterministic
begin

	declare risultato float;
	
    with medie_sensori as
    (
		select S.id, S.soglia, avg(M.xOppureUnico) as media
		from sensore S
			inner join
            misura M on S.id = M.sensore_id
            inner join
            vano V on S.vano_id = V.id
		where V.edificio_ID = _edificio	
			and S.tipologia = _tiposensore
            and M.timestamp between _datainizio and _datafine
		group by S.id
    )
    select avg(ms.media) into risultato
    from medie_sensori ms
    where ms.media > ms.soglia;
    
    return ifnull(risultato, 0);

end $$
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop function if exists media_triassiale;
delimiter $$
create function media_triassiale(_edificio int, _tiposensore varchar(50),  _data datetime, _limite int)
returns float 
deterministic
begin
	
    declare risultato float;
    
    with valori_soprasoglia as
    (
		select S.soglia, sqrt(power(M.xOppureUnico, 2)+power(M.y, 2)+power(M.z, 2)) as modulo
        from misura M
			inner join
            sensore S on S.id = M.sensore_id
            inner join
            vano V on S.vano_id = V.id
		where V.edificio_id = _edificio
			and S.tipologia = _tiposensore
            and M.timestamp <= _data
		limit _limite
    )
    select avg(vs.modulo) into risultato
    from valori_soprasoglia vs
    where vs.modulo > vs.soglia;
    
    return ifnull(risultato, 0);
    
end $$
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- stato di salute dell'edificio
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop function if exists stato_struttura;
delimiter $$
create function stato_struttura(_edificio int, _data datetime)
returns float
deterministic
begin

	declare risultato float;
    
    set risultato = media_triassiale(_edificio, 'Accelerometro', _data, 200) * costante_accelerometro()
					+ media_triassiale(_edificio, 'Giroscopio', _data, 200) * costante_giroscopio();
	
    return ifnull(risultato, 0);

end $$
delimiter ;

drop function if exists stato_muri;
delimiter $$
create function stato_muri(_edificio int, _data datetime)
returns float
deterministic
begin
	
    declare risultato float;
    
    set risultato = media_soprasoglia(_edificio, 'Estensimetro', _data, _data - interval 1 week);
    
    return ifnull(risultato, 0);

end $$
delimiter ;

drop function if exists stato_ambiente;
delimiter $$
create function stato_ambiente(_edificio int, _data datetime)
returns float
deterministic
begin

	declare risultato float;
    
    set risultato = media_soprasoglia(_edificio, 'Termometro', _data, _data - interval 1 week)
					+ media_soprasoglia(_edificio, 'Igrometro', _data, _data - interval 1 week);
	
    return ifnull(risultato, 0);

end $$
delimiter ;

drop procedure if exists stato_edificio;
delimiter $$
create procedure stato_edificio(in _edificio int, in _data datetime, out salute_edificio float)
begin
    
    set salute_edificio = (stato_struttura(_edificio, _data) * peso_struttura() 
						+ stato_muri(_edificio, _data) * peso_muri()
                        + stato_ambiente(_edificio, _data) * peso_ambiente())
                        / (peso_struttura() + peso_muri() + peso_ambiente());
    
end $$
delimiter ; 

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- distanza tra due punti sulla terra
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop function if exists distanza_punti;
delimiter $$
create function distanza_punti(lat1 decimal(9,6), long1 decimal(9,6), lat2 decimal(9,6), long2 decimal(9,6))
returns float 
deterministic
begin
	
	return ( (acos ( sin(lat1 * (pi()/180)) * sin(lat2 * (pi()/180)) 
			+ cos(lat1 * (pi()/180)) * cos(lat2 * (pi()/180)) 
			* cos((long1 - long2) * pi()/180)) * 180/pi()) * 111 );
end $$
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- calamità
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop procedure if exists stima_calamita;
delimiter $$
create procedure stima_calamita(in _edificio int, in _data datetime, in _tipocalamita varchar(45), in _latitudine float, in _longitudine float, out liv_grav int) 
begin
	declare coeff_grav float;
    declare coeff_finale float;
    declare lontananza int;
    call consigli_di_intervento(_edificio, _data);
    if _edificio is null or _data is null or _tipocalamita is null or _latitudine is null or _longitudine is null then
		signal sqlstate "45000" 
        set message_text = "I parametri di stima_calamita non sono stati inseriti correttamente";
	end if;
    set coeff_grav = (
		select distanza_punti(e.Latitudine, e.Longitudine, _latitudine, _longitudine)
		from edificio e inner join areageografica a on e.AreaGeografica_ID = a.ID
        where _edificio = e.ID
    );
    set lontananza = (
		select if(distanza_punti(e.Latitudine, e.Longitudine, _latitudine, _longitudine) between 0 and 40, 1, 0)
		from edificio e inner join areageografica a on e.AreaGeografica_ID = a.ID
        where _edificio = e.ID
    );
    if _tipocalamita = 'Sismico' then 
		set liv_grav = (
			select if(IndiceUrgenza between 0 and 30, 3, if(IndiceUrgenza between 30.000001 and 45, 2, 1))
            from consigli_di_intervento
            where lontananza = 1
        );
        set coeff_finale = (
			select IndiceUrgenza
            from consigli_di_intervento
        );
    else
		set liv_grav = (
			select if(coeff_grav between 0 and 50, 3, if(coeff_grav between 50.000001 and 100, 2, 1))
        );
		 set coeff_finale = (
			select liv_grav
        );
    end if;
    insert into calamita(Timestamp, Tipo, Intensita, Longitudine, Latitudine)
    values (current_timestamp(), _tipocalamita, coeff_finale, _latitudine, _longitudine);
end $$
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- muro_sensore: specifica il muro dov'è posizionato il sensore
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop function if exists muro_sensore;
delimiter $$
create function muro_sensore(_sensore int)
returns int 
deterministic
begin

	declare muro int;
    
    select M.id into muro
    from muro M 
		inner join
        perimetro P on M.id = P.muro_ID
        inner join
        sensore S on S.vano_id = P.vano_id
	where S.x between M.Xo and M.Xf
		and S.y between M.Yo and M.Yf
        and S.id = _sensore ;

	return muro;
end $$
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- analytic 1: consigli di intervento 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop procedure if exists consigli_di_intervento;
delimiter $$
create procedure consigli_di_intervento(in _edificio int, in _data datetime)
begin

		select 
			stato_struttura(_edificio, _data) as IndiceUrgenza,
			'Struttura edificio' as Elemento,
            if(stato_struttura(_edificio, _data) between 0 and 10, 'Nessun intervento', 
				if(stato_struttura(_edificio, _data) between 11 and 20, 'Necessaria piccola ristrutturazione entro 1 anno', 
					if(stato_struttura(_edificio, _data) between 21 and 30, 'Necessaria ristrutturazione entro 8 mesi', 
						if(stato_struttura(_edificio, _data) between 31 and 40, 'Necessaria ristrutturazione entro 4 mesi',
							if (stato_struttura(_edificio, _data) between 41 and 50, 'Necessaria ristrutturazione e grandi opere edilizie entro 2 mesi', 
								'Necessaria la ricostruzione totale della struttura'))))) as Intervento,
			null as ID_Elemento,
            null as ID_Sensore
            
		union

		select * from
        (select
			(avg(M.xOppureUnico)) * costante_estensimetro() as IndiceUrgenza,
            'Muro' as Elemento,
            if((avg(M.xOppureUnico) - S.soglia) * costante_estensimetro() between 0 and 15, 'Nessun intervento', 
				if((avg(M.xOppureUnico) - S.soglia) * costante_estensimetro() between 16 and 30,'Necessario consolidamento entro 8 mesi',
					if((avg(M.xOppureUnico) - S.soglia) * costante_estensimetro() between 31 and 45, 'Necessario consolidamento entro 2 mesi', 
						'Necessaria la ricostruzione totale del muro'))) as Intervento,
			muro_sensore(S.id) as ID_Elemento,
            S.id as ID_Sensore
		from sensore S
			inner join
            vano V on S.vano_id = v.id
			inner join
			misura M on M.sensore_id = S.id
		where V.edificio_ID = _edificio 
			and s.tipologia = 'Estensimetro'
            and M.timestamp between _data - interval 1 week and _data
            and M.xOppureUnico > S.soglia
		group by S.id
		) TMP
        
        union
        
		select * from
        (select
			(avg(M.xOppureUnico) - S.soglia) * costante_termometro() as IndiceUrgenza,
            'Vano' as Elemento,
            'Installazione impianto di climatizzazione' as Intervento,
			V.id as ID_Elemento,
            S.id as ID_Sensore
		from sensore S
			inner join
            vano V on S.vano_id = V.id
			inner join
			misura M on M.sensore_id = S.id
		where V.edificio_ID = _edificio 
			and S.tipologia = 'Termometro'
            and M.timestamp between _data - interval 1 week and _data
		group by S.id
		) TMP
        where TMP.IndiceUrgenza > 0
        
        union
        
		select * from
        (select
			(avg(M.xOppureUnico) - S.soglia) * costante_igrometro() as IndiceUrgenza,
            'Vano' as Elemento,
            'Installazione impianto di deumidificazione' as Intervento,
			V.id as ID_Elemento,
            S.id as ID_Sensore
		from sensore S
			inner join
            vano V on S.vano_id = V.id
			inner join
			misura M on M.sensore_id = S.id
		where V.edificio_ID = _edificio 
			and S.tipologia = 'Igrometro'
            and M.timestamp between _data - interval 1 week and _data
		group by S.id
		) TMP
        where TMP.IndiceUrgenza > 0
        
        order by IndiceUrgenza desc;
        
end $$
delimiter ;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- analytic 2: stima dei danni a seguito di un terremoto
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

drop procedure if exists stima_danni;
delimiter $$
create procedure stima_danni(in _edificio int, in _intensita float, in _lat decimal(9,6), in _long decimal(9,6))
begin
	declare distanza float;
    declare stato_edificio float;
    declare danno float;
    
    select distanza_punti(e.Latitudine, e.Longitudine, _lat, _long) into distanza
        from edificio e
        where _edificio = e.ID;
	
    call stato_edificio(_edificio, current_timestamp(), stato_edificio);
    
    set danno = _intensita *
				pow(distanza,2) *
                (1 + pow((1 - distanza / 100),2)) *
                (1 - stato_edificio / 50);
	
    select 
		if(danno between 0 and 20.99999, 'Danni gravi', 
			if(danno between 21 and 40.99999, 'Danni moderati', 
				if(danno between 41 and 60, 'Danni lievi', 'Danni non rilevanti'))) as Danni;

end $$
delimiter ;

