# Plano de Trabalho e Objetivos do Projeto

## Contexto
Este documento define os objetivos, fases e prazos necessários para completar o projeto de aplicação mobile.

---

## Datas Importantes

- Entrega Intermédia (20%): 4 de maio  
- Entrega Final (30%): 9 de junho  

Penalizações por atraso:
- 1º dia: -0,5 valores  
- 2º dia: -1,5 valores (acumulado)  
- 3º dia ou mais: entrega não aceite  

---

## Fase 1 — Planeamento e Setup (até 4 de maio)

### Objetivo
Definir a base do projeto e entregar uma versão inicial estruturada.

### Tarefas

#### 1. Definir a Ideia
- Escolher o conceito da aplicação  
- Identificar o público-alvo  
- Definir o problema que a app resolve  

#### 2. Definir Funcionalidades
- Funcionalidades gerais:
  - Autenticação  
  - Navegação  
  - Ecrãs básicos (ex: splash, créditos)  
- Funcionalidades específicas do tema da app  

#### 3. Escolher API Externa
- Pesquisar APIs públicas  
- Validar:
  - Disponibilidade de dados  
  - Facilidade de uso  
  - Fiabilidade  

#### 4. Definir Stack Técnica
- Firebase (Auth + Firestore)  
- Sistema de notificações  
- Gestão de estado (Provider, Riverpod, etc.)  

#### 5. Documentação Inicial
- Descrição do projeto  
- Lista de funcionalidades  
- Valor da aplicação (originalidade e utilidade)  

#### 6. Criar Mockups
- Wireframes (Figma ou equivalente)  
- Ecrãs principais:
  - Login / Registo  
  - Home  
  - Funcionalidade principal  
  - Perfil / definições  

#### 7. Definir Navegação
- Fluxo entre ecrãs  
- Jornada do utilizador  

#### 8. Setup do Repositório
- Criar repositório Git  
- Definir estrutura de pastas  
- Adicionar ficheiros base  

#### 9. Implementação Inicial da UI
- Layout básico  
- Navegação funcional  
- Sem lógica completa  

---

## Fase 2 — Desenvolvimento Principal (após 4 de maio)

### Objetivo
Implementar todas as funcionalidades obrigatórias.

### Tarefas

#### 1. Autenticação
- Login e registo  
- Integração com Firebase Auth  
- Validação e tratamento de erros  

#### 2. Integração com API
- Fazer pedidos à API  
- Mostrar dados na interface  
- Tratar:
  - Loading  
  - Erros  
  - Respostas vazias  

#### 3. Base de Dados Remota
- Definir estrutura no Firestore  
- Guardar e obter dados  

#### 4. Notificações
- Implementar notificações (push ou locais)  
- Garantir que são relevantes para a app  

#### 5. Lógica de Negócio
- Separar lógica da interface  
- Organizar o código por responsabilidades  

---

## Fase 3 — Refinamento e Entrega Final (antes de 9 de junho)

### Objetivo
Melhorar qualidade, estabilidade e preparar entrega final.

### Tarefas

#### 1. Melhorias de UI/UX
- Melhorar consistência visual  
- Adicionar feedback (loading, erro, sucesso)  
- Garantir responsividade  

#### 2. Performance
- Evitar rebuilds desnecessários  
- Usar widgets eficientes  
- Limpar código não utilizado  

#### 3. Testes e Estabilidade
- Testar todos os fluxos:
  - Autenticação  
  - API  
  - Base de dados  
  - Notificações  
- Corrigir bugs  

#### 4. Documentação
- Completar README:
  - Instalação  
  - Execução  
  - Funcionalidades  
- Adicionar comentários no código  
- Explicar decisões importantes  

#### 5. Organização Final
- Limpar e organizar ficheiros  
- Garantir histórico de commits claro  
- Remover código temporário  

---

## Checklist de Requisitos

### Obrigatórios
- Sistema de autenticação  
- Sistema de notificações  
- Integração com API externa  
- Base de dados remota  

### Qualidade Técnica
- Código organizado  
- Separação de responsabilidades  
- Boas práticas  

### UI/UX
- Design consistente  
- Boa experiência de utilizador  
- Layout responsivo  

### Documentação
- README completo  
- Explicação clara do projeto  
- Uso correto de Git  

---

## Objetivo Final

Entregar:
- Aplicação totalmente funcional  
- Código limpo e organizado  
- Projeto bem documentado  
- Interface coerente e utilizável  
- Implementação correta de todos os requisitos