# Tech Challenge Flutter

## Estrutura inicial

```
tech_challenge_flutter/
├── android/                - Estrutura de projeto nativo Android
├── ios/                    - Estrutura de projeto nativo iOS
├── lib/                    - Todos os arquivos da aplicação
│   └── components/         - Componentes reutilizáveis
│   └── core/
│   │   └── models/         - Classes de modelos de dados
│   │   └── providers/      - Gerenciamento de estado
│   │   └── providers/      - Conexão com banco de dados Firebase
│   └── screens/            - as telas principais Flutter
│   └── utils/              - arquivos de rotas e utilitários
│   └── widgets/            - Widgets reutilizáveis
│   └── main.dart           - Ponto de entrada visual da aplicação
├── linux/                  - Estrutura de projeto nativo Linux
├── macos/                  - Estrutura de projeto nativo macOS
├── test/                   - Pasta de testes
├── web/                    - Estrutura de projeto nativo Web
├── windows/                - Estrutura de projeto nativo Windows
├── .gitignore              - Arquivos ignorados pelo Git
├── .metadata               - Informações sobre a versão e configs do processo de build
├── analysis_options.yaml   - Configuração de regras de padronização do código
├── pubspec.lock            - Arquivo de travamento de dependências e scripts
├── pubspec.yaml            - Dependências e scripts (novos pacotes geralmente vem do pub.dev automaticamente)
└── README.md               - Documentação do projeto
```

## Autenticação

Autenticação via Firebase. Para acessar, registre-se ou utilize os dados abaixo no Login:

- **E-mail:** `teste@teste.com`
- **Senha:** `123456`

## Editar / Deletar transação

Deslize a transação para a esquerda e as opções ficarão disponíveis.
