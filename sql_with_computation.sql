-- sometimes Python wrapper is not necessary, as
-- some basic computation can be done right within
-- the SQL query

DECLARE @N_HYPOTH_SHARES    INT     =   100;

SELECT DISTINCT
        FORMAT (C.EffectiveDate, 'd', 'en-us') as EffectiveDate,
        K.TICKER,
 --       A.SecCode,
        A.Name,
      --  C.ActionTypeCode,
        P.Desc_,
        C.NumNewShares,
        C.NumOldShares,
        FORMAT (C.AnnouncedDate, 'd', 'en-us') as AnnouncedDate,
        FORMAT (C.RecordDate, 'd', 'en-us') as RecordDate,
        FORMAT (C.ExpiryDate, 'd', 'en-us') as ExpiryDate,
        C.OfferCmpyName,
        C.CashAmt,
    --    D.RIC,
    -- compute and format required data for an output column 
                @N_HYPOTH_SHARES    AS  NumHypothShares,

                CASE    WHEN
                                C.NumOldShares != 0
                        THEN
                                floor(@N_HYPOTH_SHARES*C.NumNewShares/C.NumOldShares)
                        ELSE
                                0
                        END     AS  NumSharesFinal,

                CASE    WHEN
                                C.NumOldShares != 0
                        THEN
                                @N_HYPOTH_SHARES*C.NumNewShares/C.NumOldShares-floor(@N_HYPOTH_SHARES*C.NumNewShares/C.NumOldShares)
                        ELSE
                                0.0
                        END     AS  LeftOverShares,

                CASE    WHEN
                                C.NumOldShares != 0
                        THEN
                            CASE    WHEN
                                        C.NumNewShares = 0
                                    THEN
                                        convert( varchar(100) , cast(0.0 as money), 1) + N'$'
                                    ELSE
                                        convert( varchar(100) , cast(((Q.Close_-C.CashAmt)/(C.NumNewShares/C.NumOldShares))*(@N_HYPOTH_SHARES*C.NumNewShares/C.NumOldShares-floor(@N_HYPOTH_SHARES*C.NumNewShares/C.NumOldShares)) as money), 1) + N'$'
                                    END
                        ELSE
                                convert( varchar(100) , cast(0.0 as money), 1) + N'$'
                        END     AS  'CashInLieu',

                CASE    WHEN
                                C.NumOldShares != 0
                        THEN    
                            CASE
                                WHEN
                                    C.NumNewShares = 0
                                           THEN
                                convert( varchar(100) , cast(@N_HYPOTH_SHARES*C.CashAmt as money), 1) + N'$'
                               ELSE
                                 convert( varchar(100) , cast(@N_HYPOTH_SHARES*C.CashAmt+((Q.Close_-C.CashAmt)/(C.NumNewShares/C.NumOldShares))*(@N_HYPOTH_SHARES*C.NumNewShares/C.NumOldShares-floor(@N_HYPOTH_SHARES*C.NumNewShares/C.NumOldShares))  as money), 1)+ N'$' 
                                END
                                
                               
                        ELSE
                                convert(varchar(100), cast(C.CashAmt    as money), 1)+ N'$'
                        END     AS  'CashFinal',
        convert(varchar(100), cast(Q.Close_     as money), 1)+ N'$' as 'Close'

        , A.*

        FROM SecMSTRX      A

        JOIN SecMapX       B
            ON A.SECCODE = B.SECCODE
            AND A.TYPE_ = 1
            AND B.VENTYPE = 33

        JOIN    DS2CapEvent     C
            ON      B.Vencode = C.InfoCode

        JOIN    DS2xRef                P 
            ON      C.ActionTypeCode = P.code

        JOIN    RDCSecMapX      M
            ON      A.SecCode = M.SecCode

        JOIN    RDCQuoteInfo    K
            ON      M.VenCode = K.QuoteID

        JOIN    RDCRICData      D
            ON      K.QuoteID = D.QuoteID
        
        JOIN    Ds2PrimqtPrc     Q
            ON      Q.infocode = C.infocode

        WHERE
        -- adjust the filter below as necessary
            -- EffectiveDate <= datediff(d, 0, getdate())
            -- AND
       --      A.SecCode in (4706, 1374)
      --      EffectiveDate >='2018-12-19'
        --    AND
       --     C.ActionTypeCode='MERG'
            -- AND 
            -- Q.MarketDate=EffectiveDate
              a.seccode in (xxx, yyy)

   ORDER BY EffectiveDate 
