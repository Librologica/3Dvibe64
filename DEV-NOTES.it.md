# Note tecniche — 1.15.0

Stabile sorgente preparata in locale e non pubblicata. La promozione da1.15.0-dev2 cambia documentazione, versione, metadati e controlli di distribuzione; mantiene tutti i byte dell'implementazione sotto work/ e tutti i moduli eseguibili/configurazioni sotto extensions/.

Inclusi aritmetica esatta, ricorrenze dei bordi, span per blocchi, outcode, adapter conservativi per pannelli, API wire/stream e codec di chiavi senza perdita. Default `legacy` e `-LegacyPlusOptimizations none` invariati. I nuovi kernel/API sono qualificati soltanto nel profilo Mode4 legacy-plus documentato; il supporto legacy-plus ordinario Mode1–7 resta distinto. Gameplay e Normalized16 conservano il proprio stato sperimentale: la versione stabile del pacchetto non amplia la loro qualifica.

[Contratto](EXACT-RENDER.it.md) · [API e limiti](REUSABLE-RENDER.it.md) · [Qualifica e provenienza](QUALIFICATION-1.15.0.it.md) · [Stato](RELEASE-STATUS.it.md).
