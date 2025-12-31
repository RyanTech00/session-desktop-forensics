# Análise Forense do Session Desktop

> **Investigação de Segurança**: Análise forense comportamental revelando vulnerabilidades de privacidade no Session Desktop

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Academic](https://img.shields.io/badge/Tipo-Investigação%20Académica-blue.svg)]()
[![Platform](https://img.shields.io/badge/Plataforma-Windows-lightgrey.svg)]()
[![OpenTimestamps](https://img.shields.io/badge/Carimbo-Bitcoin%20Blockchain-orange.svg)](https://opentimestamps.org/)

## 📋 Resumo

Este repositório documenta uma **análise forense comportamental** ao [Session Desktop](https://getsession.org/), uma aplicação de mensagens focada na privacidade que afirma oferecer encriptação de ponta a ponta e proteção de metadados.

A investigação foi realizada no âmbito de um **curso de Análise Forense Digital** num programa de Cibersegurança (CTeSP) e revela várias **vulnerabilidades de privacidade** relevantes para:

- 🔍 Investigadores forenses digitais
- 🔐 Investigadores de segurança
- 👤 Utilizadores preocupados com privacidade
- 🎓 Comunidade académica

## ⚠️ Principais Descobertas

### 1. Chave de Encriptação Armazenada em Texto Claro
A chave de encriptação da base de dados SQLCipher está armazenada **em texto claro** no ficheiro `config.json`, permitindo a qualquer pessoa com acesso ao sistema de ficheiros desencriptar toda a base de dados.

```
%AppData%\Roaming\Session\config.json
```

### 2. Mensagens Armazenadas em Texto Claro (Após Desencriptação)
Após desencriptação, todo o conteúdo das mensagens está armazenado em **texto claro** no campo `body` da tabela `messages`, sem qualquer camada adicional de encriptação.

### 3. Mensagens Eliminadas Persistem no Índice Full-Text
Quando as mensagens são eliminadas localmente, o conteúdo **permanece recuperável** na tabela `messages_fts` (Full-Text Search), mesmo após eliminação física da tabela principal.

```sql
-- Recuperar conteúdo de mensagens eliminadas
SELECT rowid, body FROM messages_fts;
```

### 4. Eliminação Remota Não Elimina Realmente
Quando um remetente usa "Limpar para todos", a mensagem no dispositivo do destinatário **NÃO é eliminada**. Em vez disso:
- O registo é **atualizado** (não eliminado)
- O campo `body` é substituído por "Esta mensagem foi apagada"
- **Os ficheiros de anexos permanecem no disco**

### 5. Anexos Persistem Após Eliminação de Mensagens
Os ficheiros na pasta `attachments.noindex` **não são removidos** quando as mensagens associadas são eliminadas, permanecendo recuperáveis com a chave de encriptação armazenada na tabela `items`.

## 📊 Resumo das Vulnerabilidades

| Vulnerabilidade | Impacto | Valor Forense |
|-----------------|---------|---------------|
| Chave de encriptação em texto claro | Crítico | Acesso total à BD |
| Mensagens em texto claro | Alto | Recuperação direta de conteúdo |
| Persistência no índice FTS | Alto | Recuperação de mensagens eliminadas |
| Falha na eliminação remota | Alto | Recuperação no dispositivo do destinatário |
| Persistência de anexos | Médio | Recuperação de ficheiros multimédia |

## 🔬 Metodologia

A análise seguiu uma abordagem sistemática com **9 cenários de teste**:

| ID | Cenário | Descrição |
|----|---------|-----------|
| C0 | Estado Inicial | Documentação de baseline |
| C1 | Criação de Conversa | Nova conversa + pedido de mensagem |
| C2 | Receção de Mensagem | Análise de mensagens recebidas |
| C3a | Eliminação Local (para mim) | Comportamento "Limpar para mim" |
| C3b | Eliminação Local (para todos) | Comportamento "Limpar para todos" |
| C4 | Envio de Anexo | Análise de upload de imagem |
| C5 | Receção de Anexo | Download de imagem + PDF |
| C6a | Receção de Áudio | Tratamento de mensagens de voz |
| C6b | Eliminação Remota | Remetente elimina "para todos" |

## 🗂️ Estrutura da Base de Dados

O Session Desktop utiliza uma base de dados **SQLite encriptada com SQLCipher** com:

- **19 tabelas**
- **25 índices**
- **3 triggers** (para sincronização FTS)

### Tabelas Principais

| Tabela | Finalidade |
|--------|------------|
| `messages` | Todas as mensagens enviadas/recebidas |
| `conversations` | Contactos e metadados de conversas |
| `messages_fts` | Índice de pesquisa full-text |
| `seenMessages` | Confirmações de leitura |
| `attachment_downloads` | Estado de download de anexos |

### Identificação de Tipos de Anexo

| Tipo | hasAttachments | hasFileAttachments | hasVisualMediaAttachments |
|------|----------------|--------------------|-----------------------------|
| Imagem/Vídeo | 1 | 0 | 1 |
| Documento | 1 | 1 | 0 |
| Áudio | 1 | 0 | 0 |

## 📁 Estrutura do Repositório

```
session-desktop-forensics/
├── README.md                 # Documentação (inglês)
├── README.pt.md              # Este ficheiro (português)
├── LICENSE                   # Licença MIT
├── docs/
│   ├── Relatorio_AFD.pdf     # Relatório académico completo
│   └── Relatorio_AFD.pdf.ots # Ficheiro de prova OpenTimestamps
├── queries/
│   ├── 01-count.sql          # Contagem de registos
│   ├── 02-messages.sql       # Análise de mensagens
│   ├── 03-conversations.sql  # Análise de conversas
│   ├── 04-fts-analysis.sql   # Análise do índice FTS (recuperação)
│   └── 05-triggers.sql       # Análise de triggers
├── findings/
│   ├── encryption-key-exposure.md   # Vulnerabilidade da chave
│   ├── fts-data-persistence.md      # Persistência no FTS
│   ├── remote-deletion-failure.md   # Falha na eliminação remota
│   └── attachment-persistence.md    # Persistência de anexos
├── evidence/                 # Capturas de ecrã das evidências
│   ├── setup/                # Configuração do ambiente
│   ├── c0-initial/           # Estado inicial
│   ├── c1-conversation/      # Criação de conversa
│   ├── c2-reception/         # Receção de mensagem
│   ├── c3a-local-deletion/   # Evidências eliminação local
│   ├── c3b-global-deletion/  # Evidências eliminação global
│   ├── c4-attachment-send/   # Envio de anexo
│   ├── c5-attachment-receive/# Receção de anexo
│   ├── c6a-audio/            # Receção de áudio
│   └── c6b-remote-deletion/  # Evidências eliminação remota
├── methodology/
│   └── test-scenarios.md     # Metodologia e cenários de teste
└── latex-source/             # Código fonte LaTeX (para académicos)
    └── Relatorio/            # Fonte completo do relatório com imagens
```

## 🛠️ Como Reproduzir

### Requisitos

- Windows 10/11
- [Session Desktop](https://getsession.org/) instalado
- [DB Browser for SQLite](https://sqlitebrowser.org/) (versão SQLCipher)

### Passos

1. **Fechar o Session Desktop** completamente

2. **Localizar a base de dados**:
   ```
   %AppData%\Roaming\Session\sql\db.sqlite
   ```

3. **Obter a chave de encriptação** de:
   ```
   %AppData%\Roaming\Session\config.json
   ```

4. **Abrir o DB Browser for SQLite** (versão SQLCipher)

5. **Configurar desencriptação**:
   - Selecionar "SQLCipher 4 defaults"
   - Alterar tipo de chave para "Raw key"
   - Inserir chave com prefixo `0x`: `0x[chave_do_config.json]`

6. **Executar as queries** da pasta `/queries`

## ⏱️ Carimbo Temporal Blockchain

Este relatório de investigação foi carimbado temporalmente utilizando **OpenTimestamps**, ancorando a sua existência à blockchain do Bitcoin. Isto proporciona:

- **Prova de Existência**: Prova criptográfica de que o documento existia numa data específica
- **Imutabilidade**: O carimbo temporal está permanentemente registado na blockchain do Bitcoin
- **Verificação**: Qualquer pessoa pode verificar independentemente o carimbo temporal

### Hash do Documento

```
SHA256: 6215ecf860a946ed4f9774d3d77f263be17fc368857a2e0e4ece217effb4bc43
```

### Verificação

1. Descarregar o PDF do relatório e o ficheiro `.ots` da pasta `docs/`
2. Visitar [OpenTimestamps.org](https://opentimestamps.org/)
3. Fazer upload de ambos os ficheiros para verificar o carimbo temporal

O ficheiro `.ots` contém a prova criptográfica que liga o hash do documento a uma transação Bitcoin.

## 📚 Referências

- Documentação Oficial do Session: https://getsession.org/
- Whitepaper Técnico do Session: https://arxiv.org/abs/2002.04609
- SQLCipher: https://www.zetetic.net/sqlcipher/
- DB Browser for SQLite: https://sqlitebrowser.org/

## ⚖️ Aviso Legal

Esta investigação foi realizada para **fins educacionais** no âmbito de um programa académico. As descobertas destinam-se a:

- Informar utilizadores sobre limitações de privacidade
- Auxiliar investigações forenses legítimas
- Contribuir para a investigação de segurança

**Não utilizar esta informação para acesso não autorizado a dados de terceiros.**

## 👥 Autores

| Autor | GitHub |
|-------|--------|
| **Ryan S.** | [@RyanTech00](https://github.com/RyanTech00) |
| **FK** | [@FK3570](https://github.com/FK3570) |
| **Hugo Correia** | [@hugocorreia2004](https://github.com/hugocorreia2004) |

Estudantes de Cibersegurança | Investigadores de Forense Digital

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - ver o ficheiro [LICENSE](LICENSE) para detalhes.

---

<p align="center">
  <i>Se consideras esta investigação útil, por favor dá uma ⭐ ao repositório!</i>
</p>
