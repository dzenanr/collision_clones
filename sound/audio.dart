part of collision_clones;

class Audio {

  AudioManager _audioManager;

  Audio() {
    _audioManager = new AudioManager('${demoBaseUrl()}/sound');
    AudioSource audioSource = _audioManager.makeSource('game');
    audioSource.positional = false;
    AudioClip collisionSound =
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

  AudioManager get audioManager => _audioManager;

}
