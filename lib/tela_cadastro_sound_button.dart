import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'model/sound_button_model.dart'; // Importa o modelo de dados dos botões

// TelaCadastroSoundButton é usada para criar ou editar um botão de som.
// Interage com TelaInicialSoundpad retornando um SoundButtonModel novo ou editado.
class TelaCadastroSoundButton extends StatefulWidget {
  final SoundButtonModel? button;
  const TelaCadastroSoundButton({Key? key, this.button}) : super(key: key);

  @override
  // Cria o estado associado a esta tela de cadastro.
  State<TelaCadastroSoundButton> createState() => _TelaCadastroSoundButtonState();
}

class _TelaCadastroSoundButtonState extends State<TelaCadastroSoundButton> {
  // Controla o formulário de cadastro.
  final _formKey = GlobalKey<FormState>();
  // Controla o campo de nome do botão.
  late TextEditingController _nomeController;
  // Caminho do arquivo de áudio selecionado.
  String? _audioPath;
  // Cor do botão selecionada.
  Color _buttonColor = Colors.indigo.shade100;

  @override
  void initState() {
    super.initState();
    // Inicializa o campo de nome e os valores iniciais se estiver editando.
    // Recebe dados de TelaInicialSoundpad via widget.button.
    _nomeController = TextEditingController(text: widget.button?.nome ?? '');
    _audioPath = widget.button?.audioPath;
    if (widget.button?.cor != null) {
      _buttonColor = _parseColor(widget.button!.cor!);
    }
  }

  // Abre o seletor de arquivos para escolher um áudio.
  // Atualiza o caminho do áudio selecionado.
  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioPath = result.files.single.path;
      });
    }
  }

  // Abre o seletor de cor customizado.
  // Atualiza a cor do botão selecionada.
  Future<void> _pickColor() async {
    Color? picked = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Escolha uma cor'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _buttonColor,
            onColorChanged: (color) => Navigator.of(context).pop(color),
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _buttonColor = picked;
      });
    }
  }

  // Salva o botão criado ou editado.
  // Retorna o botão para TelaInicialSoundpad usando Navigator.pop.
  // Interage com TelaInicialSoundpad, que recebe o resultado e atualiza a lista.
  void _save() {
    if (!_formKey.currentState!.validate() || _audioPath == null) return;
    final btn = SoundButtonModel(
      id: widget.button?.id,
      nome: _nomeController.text,
      audioPath: _audioPath!,
      cor: _buttonColor.value.toString(),
    );
    Navigator.pop(context, btn);
  }

  @override
  Widget build(BuildContext context) {
    // Monta a interface do formulário de cadastro.
    // Usa as funções acima para manipular os campos e salvar o botão.
    // Interage com TelaInicialSoundpad ao retornar o botão criado/editado.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.button == null ? 'Adicionar Audio' : 'Editar audio'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome do botão'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _audioPath == null ? 'Nenhum áudio selecionado' : _audioPath!,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.audiotrack),
                    onPressed: _pickAudio,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Cor do botão:'),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickColor,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _buttonColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _save,
                child: Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Converte a string de cor salva no modelo para um objeto Color.
  // Usada ao exibir o botão com a cor correta. Interage com o modelo SoundButtonModel.
  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      colorString = colorString.replaceFirst('#', '');
      if (colorString.length == 6) {
        colorString = 'FF' + colorString;
      }
      return Color(int.parse(colorString, radix: 16));
    } else if (int.tryParse(colorString) != null) {
      return Color(int.parse(colorString));
    } else {
      return Colors.indigo.shade100;
    }
  }
}

// Widget customizado para seleção de cor.
// Usado em _pickColor para permitir ao usuário escolher uma cor.
// Interage apenas internamente nesta tela.
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  const BlockPicker({required this.pickerColor, required this.onColorChanged});

  static const List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    // Exibe as opções de cor para o usuário selecionar.
    // Interage apenas internamente nesta tela.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colors.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: pickerColor == color ? Colors.black : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }).toList(),
    );
  }
}
