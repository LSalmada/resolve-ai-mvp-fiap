# frozen_string_literal: true

DEMO_PASSWORD = "password123"

manager = User.find_or_initialize_by(email: "manager@resolve.ai")
manager.assign_attributes(name: "Síndica", password: DEMO_PASSWORD, password_confirmation: DEMO_PASSWORD, role: :manager)
manager.save!

requester = User.find_or_initialize_by(email: "requester@resolve.ai")
requester.assign_attributes(name: "Lucas Souza", password: DEMO_PASSWORD, password_confirmation: DEMO_PASSWORD, role: :requester)
requester.save!

marina = User.find_or_initialize_by(email: "marina@resolve.ai")
marina.assign_attributes(name: "Camila Loureiro", password: DEMO_PASSWORD, password_confirmation: DEMO_PASSWORD, role: :requester)
marina.save!

Occurrence.destroy_all

def transition!(occurrence, to:, actor:, note: nil, **attrs)
  from = occurrence.status
  occurrence.assign_attributes(attrs.merge(status: to))
  occurrence.save!
  occurrence.record_event!(event_type: :status_changed, user: actor, from_status: from, to_status: to, note: note)
end

def assign!(occurrence, actor:, assignee:, note: nil)
  occurrence.update!(assignee: assignee)
  occurrence.record_event!(event_type: :assignee_changed, user: actor, note: note || "Responsável: #{assignee.name}")
end

def prioritize!(occurrence, actor:, priority:, note: nil)
  from = occurrence.priority
  occurrence.update!(priority: priority)
  occurrence.record_event!(event_type: :priority_changed, user: actor, note: note || "Prioridade de #{from} para #{priority}")
end

lampada = Occurrence.create!(
  reporter: requester,
  title: "Lâmpada queimada no corredor",
  description: "O corredor do 3º andar está sem iluminação desde ontem à noite.",
  location: "Bloco B, 3º andar",
  category: :lighting,
  priority: :medium
)
lampada.photo.attach(
  io: File.open(Rails.root.join("db/seeds/files/photo.png")),
  filename: "iluminacao.png",
  content_type: "image/png"
)

elevador = Occurrence.create!(
  reporter: requester,
  title: "Elevador com ruído anormal",
  description: "O elevador social treme e faz um estalo ao parar no 2º andar.",
  location: "Bloco A, elevador social",
  category: :equipment,
  priority: :medium
)
prioritize!(elevador, actor: manager, priority: :high, note: "Equipamento crítico de circulação")
assign!(elevador, actor: manager, assignee: manager)
transition!(elevador, to: :in_analysis, actor: manager, note: "Acionada a empresa de manutenção.")

vazamento = Occurrence.create!(
  reporter: requester,
  title: "Vazamento no térreo",
  description: "Há uma poça crescente perto da portaria, possivelmente de encanamento.",
  location: "Térreo, hall da portaria",
  category: :leakage,
  priority: :medium
)
prioritize!(vazamento, actor: manager, priority: :urgent)
assign!(vazamento, actor: manager, assignee: manager)
transition!(vazamento, to: :in_analysis, actor: manager, note: "Vistoria inicial feita.")
transition!(vazamento, to: :in_progress, actor: manager, note: "Encanador a caminho.")

rampa = Occurrence.create!(
  reporter: requester,
  title: "Rampa de acesso danificada",
  description: "A rampa da entrada principal tem um desnível que impede cadeira de rodas.",
  location: "Entrada principal",
  category: :accessibility,
  priority: :high
)
assign!(rampa, actor: manager, assignee: manager)
transition!(rampa, to: :in_analysis, actor: manager, note: "Medição do desnível.")
transition!(rampa, to: :in_progress, actor: manager, note: "Obra de correção iniciada.")
transition!(
  rampa,
  to: :resolved,
  actor: manager,
  note: "Rampa regularizada.",
  resolution_notes: "Reconstrução da rampa com piso antiderrapante e corrimão."
)
rampa.update!(rating: 5, rating_comment: "Ficou excelente, obrigado.")

lixo = Occurrence.create!(
  reporter: requester,
  title: "Lixo acumulado na área gourmet",
  description: "As lixeiras transbordaram depois do evento de sábado.",
  location: "Bloco C, área gourmet",
  category: :cleaning,
  priority: :low
)
transition!(lixo, to: :cancel, actor: manager, note: "Equipe de limpeza já havia recolhido antes da abertura.")

Occurrence.create!(
  reporter: marina,
  title: "Portão da garagem aberto à noite",
  description: "O portão automático não fecha sozinho após a passagem do carro.",
  location: "Garagem subterrânea",
  category: :security,
  priority: :urgent
)

Occurrence.create!(
  reporter: requester,
  title: "Ar-condicionado do salão pingando",
  description: "O aparelho do salão de festas pingou no piso durante o ensaio.",
  location: "Salão de festas",
  category: :maintenance,
  priority: :medium
)

Occurrence.create!(
  reporter: requester,
  title: "Barulho excessivo na cobertura",
  description: "Obra na cobertura aos domingos fora do horário permitido.",
  location: "Cobertura, Bloco B",
  category: :other,
  priority: :low
)

Comment.create!(occurrence: elevador, user: requester, body: "O ruído aumentou hoje de manhã.")
Comment.create!(occurrence: elevador, user: manager, body: "Obrigado. Vamos priorizar a visita técnica.")
Comment.create!(occurrence: vazamento, user: manager, body: "Isolamos a área e avisamos os moradores.")

puts "Seeds OK — manager@resolve.ai / requester@resolve.ai / marina@resolve.ai (senha: #{DEMO_PASSWORD})"
