# Cloudwatch Monitoring
[![Build Status](https://travis-ci.com/j-sokol/CloudwatchMonitoring.svg?branch=master)](https://travis-ci.com/j-sokol/CloudwatchMonitoring)

Lightweight monitoring solution to notify yourself of statuses of your servers & applications. Currently supports only Slack as an output, but that's easily extensible.


## How it works

```
+--------------------+                +-------------------+
|Server Metrics      +--------+       |Alarms Definition  |
|(via Telegraf)      |        |       |(Alarms lambda fn) |
+--------------------+        |       +-----------------+-+
                              v                         |
+--------------------+    +-------------------------+   |    +-----------   +-----------------+
|Application Uptime  |    |          CloudWatch     | <-+    |Amazon SNS|   |Slack message    |
|Metrics (Uptime     +--->|                         |        |Topic     +-->|(via Slack notify|
|Lambda fn)          |    |Timeseries DB  ->  Alarms|------->|          |   |Lambda fn)       |
+--------------------+    +-------------------------+        +-----------   +-----------------+
```
## How to deploy

## Running tests


## Zadání semestrálky

Vytvoření vlastního monitoringu, který bude high-available a spolehlivý, může dát velmi práce. Proto bych si rád vybral téma této semestrálky - jednoduchý monitoring postavený na AWS službách - CloudWatch pro time series databázi a alerty při překročení tresholdů, SNS na posílání zpráv mezi mikroslužbami a konečně Lambda pro serverless spouštění jednotlivých služeb.

Tyto služby jsou následující:
- Lambda pro querry jednotlivých metrik, které pak budou odeslány do timeseries databáze
  - spouštěna každou ~minutu
  - zdroje metrik většinou výstupy z různých API endpointů
  - jednoduché vytvoření nových monitorovacích pravidel/endpointů
- Služba vytvářející alarmy, pokud metrika přesáhne nějaký treshold
  - spouštěna při nějakém eventu?/jednou za hodinu
  - zjistí z API všechny moje servery a priřádí jim základní alerty, pro které už metriky v CloudWatchi existují implicitně (server je spuštěn, cpu load nad určitou hodnotou, atp.)
  - alarmy definované jen pro určité služby - definováno dle tagů v AWS
- Služba přijímající eventy ze SNS topicu (obsahující alerty[1]), přeposílající tyto eventy na Slack
s rosšířitelností na jiné služby (Telegram, Spectrum, Gitter, atp)


Řešení deploymentu pomocí Terraformu[2].

Jednotlivé funkce otestovány unit testy.





[1] https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html
[2] https://www.terraform.io/docs/providers/aws/r/lambda_function.html
