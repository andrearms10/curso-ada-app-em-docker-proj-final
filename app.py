import os
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# LER as variáveis de ambiente do Kubernetes
db_user = os.environ.get('DB_USER', 'admin')
db_password = os.environ.get('DB_PASSWORD', 'admin123')
db_host = os.environ.get('DB_HOST', 'postgres-service')
db_name = os.environ.get('DB_NAME', 'produtosdb')

# CONSTRUIR a URL dinamicamente
database_url = f'postgresql://{db_user}:{db_password}@{db_host}:5432/{db_name}'
app.config['SQLALCHEMY_DATABASE_URI'] = database_url

db = SQLAlchemy(app)

class Produto(db.Model):
    __tablename__ = 'produtos'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    nome = db.Column(db.String(50), nullable=False)

    def to_dict(self):
        return {'id': self.id, 'nome': self.nome}

@app.route('/produtos', methods=['POST'])
def criar_produto():
    dados = request.get_json()
    
    if not dados or 'nome' not in dados or not dados['nome'].strip():
        return jsonify({'erro': 'Campo "nome" é obrigatório'}), 400
    
    produto = Produto(nome=dados['nome'])
    db.session.add(produto)
    db.session.commit()
    return jsonify(produto.to_dict()), 201

@app.route('/produtos', methods=['GET'])
def listar_produtos():
    produtos = Produto.query.all()
    return jsonify([p.to_dict() for p in produtos])

@app.route('/produtos/<int:id>', methods=['GET'])
def obter_produto(id):
    produto = Produto.query.get_or_404(id)
    return jsonify(produto.to_dict())

@app.route('/produtos/<int:id>', methods=['PUT'])
def atualizar_produto(id):
    produto = Produto.query.get_or_404(id)
    dados = request.get_json()
    
    if not dados or 'nome' not in dados or not dados['nome'].strip():
        return jsonify({'erro': 'Campo "nome" é obrigatório'}), 400
    
    produto.nome = dados['nome']
    db.session.commit()
    return jsonify(produto.to_dict())

@app.route('/produtos/<int:id>', methods=['DELETE'])
def deletar_produto(id):
    produto = Produto.query.get_or_404(id)
    db.session.delete(produto)
    db.session.commit()
    return '', 204

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)