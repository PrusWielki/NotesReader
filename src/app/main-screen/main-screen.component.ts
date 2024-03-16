import { Component } from '@angular/core';
import { NoteCardComponent } from '../note-card/note-card.component';

@Component({
  selector: 'app-main-screen',
  standalone: true,
  imports: [NoteCardComponent],
  templateUrl: './main-screen.component.html',
  styleUrl: './main-screen.component.scss',
})
export class MainScreenComponent {
  cards = [
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
    { text: 'asdasdasdsadasdasd' },
  ];
}
