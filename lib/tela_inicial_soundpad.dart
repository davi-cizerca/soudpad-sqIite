import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'model/sound_button_model.dart'; // Importa o modelo de dados usado para os botões
import 'tela_cadastro_sound_button.dart'; // Importa a tela de cadastro/edição de botões
import 'dart:async';

// TelaInicialSoundpad é a tela principal do app. Ela exibe os botões de som e permite adicionar, editar e remover botões.
// Interage com TelaCadastroSoundButton para adicionar/editar botões e com SoundButtonModel para estruturar os dados dos botões.
class TelaInicialSoundpad extends StatefulWidget {
  const TelaInicialSoundpad({super.key});

  @override
  State<TelaInicialSoundpad> createState() => _TelaInicialSoundpadState();
}

class _TelaInicialSoundpadState extends State<TelaInicialSoundpad> {
  // Lista de botões de som exibidos na tela. Manipulada pelas funções de adicionar, editar e remover.
  // Cada item é um SoundButtonModel, definido em model/sound_button_model.dart
  List<SoundButtonModel> buttons = [
    SoundButtonModel(id: 1, nome: 'Exemplo 1', audioPath: 'audio1.mp3', cor: '#2196F3'),
    SoundButtonModel(id: 2, nome: 'Exemplo 2', audioPath: 'audio2.mp3', cor: '#F44336'),
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _nextId = 3;

  // Toca o áudio associado ao botão pressionado.
  // Interage com o método onTap do GestureDetector.
  void _playSound(String path) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
  }

  // Remove um botão da lista pelo id.
  // É chamada após o usuário segurar pressionado por 1 segundo.
  void _deleteButton(int id) {
    setState(() {
      buttons.removeWhere((btn) => btn.id == id);
    });
  }

  // Adiciona um novo botão ou edita um existente.
  // Abre a TelaCadastroSoundButton e, ao retornar, atualiza a lista de botões.
  // Se button for null, adiciona; senão, edita.
  // Interage diretamente com TelaCadastroSoundButton (para cadastro/edição) e com SoundButtonModel (dados do botão).
  void _addOrEditButton([SoundButtonModel? button]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastroSoundButton(button: button), // Chama a tela de cadastro/edição
      ),
    );
    if (result is SoundButtonModel) {
      setState(() {
        if (button == null) {
          result.id = _nextId++;
          buttons.add(result);
        } else {
          final idx = buttons.indexWhere((b) => b.id == button.id);
          if (idx != -1) {
            buttons[idx] = result;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Monta a interface principal, exibindo os botões e ações.
    // Usa as funções acima para manipular a lista e responder a eventos.
    // Interage com TelaCadastroSoundButton ao adicionar/editar e com SoundButtonModel para exibir os dados.
    return Scaffold(
      appBar: AppBar(
        title: Text('SoundPad'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'Créditos',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Créditos'),
                  content: Text('Este aplicativo foi desenvolvido por Davi Cizerça para a matéria de Desenvolvimento para Dispositivos Móveis do professor Heitor Scalco Neto.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: buttons.length,
          itemBuilder: (context, index) {
            final btn = buttons[index];
            // Cada botão pode ser pressionado para tocar o som ou segurado para remover.
            // Interage com _playSound (tocar) e _deleteButton (remover).
            return GestureDetector(
              onTap: () => _playSound(btn.audioPath),
              onLongPressStart: (details) {
                Timer? holdTimer;
                holdTimer = Timer(Duration(seconds: 1), () {
                  _deleteButton(btn.id!);
                  holdTimer = null;
                });
                void cancelTimer() {
                  if (holdTimer != null) {
                    holdTimer!.cancel();
                    holdTimer = null;
                  }
                }
                GestureDetector(
                  onLongPressEnd: (_) => cancelTimer(),
                  onLongPressUp: cancelTimer,
                  child: Container(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color:
                      btn.cor != null
                          ? _parseColor(btn.cor!)
                          : Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        btn.nome,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditButton(), // Chama a tela de cadastro/edição
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
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
    } else {
      return Colors.indigo.shade100;
    }
  }
}
