part of collision_clones;

class Audio {

  sa.AudioManager _audioManager;

  Audio() {
    _audioManager = new sa.AudioManager('${demoBaseUrl()}/sound');
    sa.AudioSource audioSource = _audioManager.makeSource('game');
    audioSource.positional = false;
    sa.AudioClip collisionSound =
        _audioManager.makeClip('collision', 'collision.ogg');
    collisionSound.load();
  }

  String demoBaseUrl() {
    String location = window.location.href;
    int slashIndex = location.lastIndexOf('/');
    if (slashIndex < 0) {
      return '/';
    } else {
      return location.substring(0, slashIndex);
    }
  }

  sa.AudioManager get audioManager => _audioManager;

}
