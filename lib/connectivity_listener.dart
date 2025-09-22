import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kyc/presentation/blocs/sync_bloc.dart';

class ConnectivityListener {
  final SyncBloc syncBloc;

  ConnectivityListener(this.syncBloc) {
    Connectivity().onConnectivityChanged.listen((status) {
      print("Connectivity changed: $status");
      if (status.contains(ConnectivityResult.none)) {
        syncBloc.add(NetworkOnlineEvent());
      }
    });
  }
}
